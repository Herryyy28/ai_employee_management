import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/dio_client.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/leaves/domain/repositories/leaves_repository.dart';
import '../../features/leaves/data/repositories/leaves_repository_impl.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../../features/tasks/data/repositories/tasks_repository_impl.dart';
import '../../services/ai_service.dart';
import '../config/env.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  static Future<void> setup() async {
    // 1. Core Services
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
    sl.registerLazySingleton<DioClient>(() => DioClient());
    sl.registerLazySingleton<AiService>(() {
      if (Env.geminiApiKey.isNotEmpty) {
        return GeminiAiServiceImpl(Env.geminiApiKey);
      }
      return MockAiServiceImpl();
    });

    // 2. Repositories
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
    sl.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
    sl.registerLazySingleton<LeavesRepository>(
      () => LeavesRepositoryImpl(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
    sl.registerLazySingleton<TasksRepository>(
      () => TasksRepositoryImpl(
        supabaseClient: sl<SupabaseClient>(),
      ),
    );
  }
}
