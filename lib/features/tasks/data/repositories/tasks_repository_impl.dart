import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../../../../core/database/hive_keys.dart';

class TasksRepositoryImpl implements TasksRepository {
  final SupabaseClient _supabaseClient;
  final Box _tasksBox;
  final Box _offlineQueueBox;

  TasksRepositoryImpl({
    required SupabaseClient supabaseClient,
  })  : _supabaseClient = supabaseClient,
        _tasksBox = Hive.box(HiveBoxKeys.tasksBox),
        _offlineQueueBox = Hive.box(HiveBoxKeys.offlineQueueBox);

  @override
  Future<void> createTask(TaskModel task) async {
    final rawJson = task.toJson();
    final localKey = 'task_${task.companyId}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Cache local
    await _tasksBox.put(localKey, jsonEncode(rawJson));

    try {
      await _supabaseClient.from('tasks').insert(rawJson);
    } catch (e) {
      // Sync queue fallback
      final queueKey = 'task_create_${DateTime.now().millisecondsSinceEpoch}';
      await _offlineQueueBox.put(queueKey, {
        'type': 'task_create',
        'data': rawJson,
      });
    }
  }

  @override
  Future<List<TaskModel>> getTasks(String companyId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('tasks')
          .select()
          .eq('company_id', companyId);

      final list = response.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
      
      // Update local storage
      for (var model in list) {
        if (model.id != null) {
          await _tasksBox.put(model.id, jsonEncode(model.toJson()));
        }
      }
      return list;
    } catch (e) {
      // Offline fallback: load all records matching companyId
      final List<TaskModel> cachedList = [];
      for (var value in _tasksBox.values) {
        try {
          final Map<String, dynamic> json = jsonDecode(value as String) as Map<String, dynamic>;
          if (json['company_id'] == companyId) {
            cachedList.add(TaskModel.fromJson(json));
          }
        } catch (_) {}
      }
      return cachedList;
    }
  }

  @override
  Future<void> updateTaskStatus({
    required String id,
    required String status,
  }) async {
    final updateData = {'status': status};

    try {
      await _supabaseClient.from('tasks').update(updateData).eq('id', id);
    } catch (e) {
      // Local cache update
      final cached = _tasksBox.get(id) as String?;
      if (cached != null) {
        final Map<String, dynamic> json = jsonDecode(cached) as Map<String, dynamic>;
        json['status'] = status;
        await _tasksBox.put(id, jsonEncode(json));
      }

      // Sync queue
      final queueKey = 'task_status_${DateTime.now().millisecondsSinceEpoch}';
      await _offlineQueueBox.put(queueKey, {
        'type': 'task_status',
        'id': id,
        'data': updateData,
      });
    }
  }
}
