import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../../../core/database/hive_keys.dart';
import '../../../../core/network/failure.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final SupabaseClient _supabaseClient;
  final Box _attendanceBox;
  final Box _offlineQueueBox;

  AttendanceRepositoryImpl({
    required SupabaseClient supabaseClient,
  })  : _supabaseClient = supabaseClient,
        _attendanceBox = Hive.box(HiveBoxKeys.attendanceBox),
        _offlineQueueBox = Hive.box(HiveBoxKeys.offlineQueueBox);

  @override
  Future<void> clockIn(AttendanceModel attendance) async {
    final Map<String, dynamic> rawJson = attendance.toJson();
    final localKey = 'today_${attendance.employeeId}_${attendance.date}';

    // 1. Always save locally first (Optimistic UI & Offline support)
    await _attendanceBox.put(localKey, jsonEncode(rawJson));

    try {
      // 2. Attempt remote save
      final response = await _supabaseClient
          .from('attendance')
          .insert(rawJson)
          .select()
          .single();
      
      // Update local storage with Supabase returned ID
      final savedModel = AttendanceModel.fromJson(response);
      await _attendanceBox.put(localKey, jsonEncode(savedModel.toJson()));
    } catch (e) {
      // 3. Fallback: Queue execution for background synchronization
      final queueKey = 'clock_in_${DateTime.now().millisecondsSinceEpoch}';
      await _offlineQueueBox.put(queueKey, {
        'type': 'clock_in',
        'data': rawJson,
      });
      
      // We don't throw error to UI since we support offline check-ins
      debugPrint('Clock In cached locally. Will sync when online.');
    }
  }

  @override
  Future<void> clockOut({
    required String id,
    required DateTime time,
    double? lat,
    double? lng,
    bool qrVerified = false,
  }) async {
    final updateData = {
      'clock_out': time.toIso8601String(),
      'gps_lat_out': lat,
      'gps_lng_out': lng,
      'qr_verified_out': qrVerified,
    };

    try {
      // Update remote Supabase
      await _supabaseClient
          .from('attendance')
          .update(updateData)
          .eq('id', id);
          
      // Fetch details and update cache
      final fresh = await _supabaseClient.from('attendance').select().eq('id', id).single();
      final freshModel = AttendanceModel.fromJson(fresh);
      final localKey = 'today_${freshModel.employeeId}_${freshModel.date}';
      await _attendanceBox.put(localKey, jsonEncode(freshModel.toJson()));
    } catch (e) {
      // Cache update local only
      final cachedJson = _attendanceBox.values.firstWhere(
        (v) {
          try {
            final parsed = jsonDecode(v.toString());
            return parsed['id'] == id;
          } catch (_) {
            return false;
          }
        },
        orElse: () => null,
      );

      if (cachedJson != null) {
        final parsed = jsonDecode(cachedJson) as Map<String, dynamic>;
        parsed.addAll(updateData);
        final freshModel = AttendanceModel.fromJson(parsed);
        final localKey = 'today_${freshModel.employeeId}_${freshModel.date}';
        await _attendanceBox.put(localKey, jsonEncode(freshModel.toJson()));
      }

      // Add to offline sync queue
      final queueKey = 'clock_out_${DateTime.now().millisecondsSinceEpoch}';
      await _offlineQueueBox.put(queueKey, {
        'type': 'clock_out',
        'id': id,
        'data': updateData,
      });
    }
  }

  @override
  Future<List<AttendanceModel>> getHistory(String employeeId) async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('attendance')
          .select()
          .eq('employee_id', employeeId)
          .order('date', ascending: false);

      final List<AttendanceModel> remoteList = response
          .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Overwrite local cache with fresh remote logs
      for (var model in remoteList) {
        final localKey = 'today_${model.employeeId}_${model.date}';
        await _attendanceBox.put(localKey, jsonEncode(model.toJson()));
      }

      return remoteList;
    } catch (e) {
      // Offline fallback: load all records matching employeeId from Hive
      final List<AttendanceModel> cachedList = [];
      for (var value in _attendanceBox.values) {
        try {
          final Map<String, dynamic> json = jsonDecode(value as String) as Map<String, dynamic>;
          if (json['employee_id'] == employeeId) {
            cachedList.add(AttendanceModel.fromJson(json));
          }
        } catch (_) {}
      }
      // Sort descending by date
      cachedList.sort((a, b) => b.date.compareTo(a.date));
      return cachedList;
    }
  }

  @override
  Future<AttendanceModel?> getTodayStatus(String employeeId, String date) async {
    final localKey = 'today_${employeeId}_$date';
    final cached = _attendanceBox.get(localKey) as String?;
    
    if (cached != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(cached) as Map<String, dynamic>;
        return AttendanceModel.fromJson(json);
      } catch (_) {}
    }

    try {
      final response = await _supabaseClient
          .from('attendance')
          .select()
          .eq('employee_id', employeeId)
          .eq('date', date)
          .maybeSingle();

      if (response != null) {
        final model = AttendanceModel.fromJson(response);
        await _attendanceBox.put(localKey, jsonEncode(model.toJson()));
        return model;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
