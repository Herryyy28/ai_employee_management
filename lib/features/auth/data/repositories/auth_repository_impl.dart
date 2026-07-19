import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/database/hive_keys.dart';
import '../../../../core/network/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final sb.SupabaseClient _supabaseClient;
  final Box _authBox;

  AuthRepositoryImpl({
    required sb.SupabaseClient supabaseClient,
  })  : _supabaseClient = supabaseClient,
        _authBox = Hive.box(HiveBoxKeys.authBox);

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Perform authentication via Supabase Auth
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final sbUser = response.user;
      if (sbUser == null) {
        throw const AuthFailure('Login failed: User record is empty.');
      }

      // 2. Fetch employee profile corresponding to auth ID
      final profileData = await _supabaseClient
          .from('employees')
          .select()
          .eq('id', sbUser.id)
          .single();

      final userModel = UserModel.fromJson(profileData);

      // 3. Cache the employee model locally in Hive for offline access
      await _authBox.put(HiveBoxKeys.userProfileKey, jsonEncode(userModel.toJson()));
      await _authBox.put(HiveBoxKeys.tenantIdKey, userModel.companyId);

      return userModel;
    } catch (e) {
      throw FailureHandler.handle(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      // Clear cache
      await _authBox.delete(HiveBoxKeys.userProfileKey);
      await _authBox.delete(HiveBoxKeys.tenantIdKey);
    } catch (e) {
      throw FailureHandler.handle(e);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        // No remote session, check local cache for offline usage
        return _getLocalCachedUser();
      }

      final userId = session.user.id;
      final profileData = await _supabaseClient
          .from('employees')
          .select()
          .eq('id', userId)
          .single();

      final userModel = UserModel.fromJson(profileData);
      
      // Update cache
      await _authBox.put(HiveBoxKeys.userProfileKey, jsonEncode(userModel.toJson()));
      await _authBox.put(HiveBoxKeys.tenantIdKey, userModel.companyId);

      return userModel;
    } catch (e) {
      // Offline fallback
      return _getLocalCachedUser();
    }
  }

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    return _supabaseClient.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) {
        await _authBox.delete(HiveBoxKeys.userProfileKey);
        await _authBox.delete(HiveBoxKeys.tenantIdKey);
        return null;
      }
      return getCurrentUser();
    });
  }

  UserEntity? _getLocalCachedUser() {
    final cachedData = _authBox.get(HiveBoxKeys.userProfileKey) as String?;
    if (cachedData != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(cachedData) as Map<String, dynamic>;
        return UserModel.fromJson(json);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
