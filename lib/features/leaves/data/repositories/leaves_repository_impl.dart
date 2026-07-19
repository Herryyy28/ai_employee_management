import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/leave_model.dart';
import '../../domain/repositories/leaves_repository.dart';
import '../../../../core/database/hive_keys.dart';

class LeavesRepositoryImpl implements LeavesRepository {
  final SupabaseClient _supabaseClient;
  final Box _leavesBox;
  final Box _offlineQueueBox;

  LeavesRepositoryImpl({
    required SupabaseClient supabaseClient,
  })  : _supabaseClient = supabaseClient,
        _leavesBox = Hive.box(HiveBoxKeys.leavesBox),
        _offlineQueueBox = Hive.box(HiveBoxKeys.offlineQueueBox);

  @override
  Future<void> submitLeave(LeaveModel leave) async {
    final rawJson = leave.toJson();
    final localKey = 'leave_${leave.employeeId}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Save locally
    await _leavesBox.put(localKey, jsonEncode(rawJson));

    try {
      // remote post
      await _supabaseClient.from('leaves').insert(rawJson);
    } catch (e) {
      // offline queue fallback
      final queueKey = 'leave_submit_${DateTime.now().millisecondsSinceEpoch}';
      await _offlineQueueBox.put(queueKey, {
        'type': 'leave_submit',
        'data': rawJson,
      });
    }
  }

  @override
  Future<List<LeaveModel>> getLeaves(String employeeId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('leaves')
          .select()
          .eq('employee_id', employeeId)
          .order('created_at', ascending: false);

      final list = response.map((item) => LeaveModel.fromJson(item as Map<String, dynamic>)).toList();
      
      // Update local storage
      for (var model in list) {
        if (model.id != null) {
          await _leavesBox.put(model.id, jsonEncode(model.toJson()));
        }
      }
      return list;
    } catch (e) {
      // Offline logs matching employeeId
      final List<LeaveModel> cachedList = [];
      for (var value in _leavesBox.values) {
        try {
          final Map<String, dynamic> json = jsonDecode(value as String) as Map<String, dynamic>;
          if (json['employee_id'] == employeeId) {
            cachedList.add(LeaveModel.fromJson(json));
          }
        } catch (_) {}
      }
      return cachedList;
    }
  }

  @override
  Future<List<LeaveModel>> getCompanyLeaves(String companyId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('leaves')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return response.map((item) => LeaveModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback: load all cached items in box
      final List<LeaveModel> cachedList = [];
      for (var value in _leavesBox.values) {
        try {
          final Map<String, dynamic> json = jsonDecode(value as String) as Map<String, dynamic>;
          if (json['company_id'] == companyId) {
            cachedList.add(LeaveModel.fromJson(json));
          }
        } catch (_) {}
      }
      return cachedList;
    }
  }

  @override
  Future<void> updateLeaveStatus({
    required String id,
    required String status,
    required String approvedBy,
    String? comments,
  }) async {
    final updateData = {
      'status': status,
      'approved_by': approvedBy,
      'admin_comments': comments,
    };

    try {
      await _supabaseClient.from('leaves').update(updateData).eq('id', id);
    } catch (e) {
      // Save locally
      final cached = _leavesBox.get(id) as String?;
      if (cached != null) {
        final Map<String, dynamic> json = jsonDecode(cached) as Map<String, dynamic>;
        json.addAll(updateData);
        await _leavesBox.put(id, jsonEncode(json));
      }

      // Add to offline sync queue
      final queueKey = 'leave_review_${DateTime.now().millisecondsSinceEpoch}';
      await _offlineQueueBox.put(queueKey, {
        'type': 'leave_review',
        'id': id,
        'data': updateData,
      });
    }
  }
}
