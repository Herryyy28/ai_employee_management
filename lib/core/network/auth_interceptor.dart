import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import '../config/service_locator.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Inject Supabase API key (required by Supabase edge functions / REST endpoint headers)
    options.headers['apikey'] = Env.supabaseAnonKey;
    
    // 2. Fetch current active session token and append as Authorization Bearer
    try {
      final session = sl<SupabaseClient>().auth.currentSession;
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
    } catch (_) {
      // Safe fallback if Supabase client is not fully initialized
    }

    return handler.next(options);
  }
}
