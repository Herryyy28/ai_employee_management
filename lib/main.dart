import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env.dart';
import 'core/config/service_locator.dart';
import 'core/database/hive_setup.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local cache database (Hive)
  await HiveSetup.init();

  // 2. Initialize Supabase with error mitigation for placeholder keys
  try {
    if (Env.supabaseUrl.contains('placeholder') || Env.supabaseAnonKey.contains('placeholder')) {
      debugPrint('WARNING: Supabase keys are placeholders. Continuing in offline mode.');
    }
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    ServiceLocator.isSupabaseInitialized = true;
  } catch (e) {
    debugPrint('Supabase initialization failed: $e. Operating in fallback cache mode.');
  }

  // 3. Register singletons via GetIt service locator
  await ServiceLocator.setup();

  // 4. Run the app wrapped in a Riverpod ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AI Employee Management Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically toggle Light & Dark themes
      routerConfig: router,
    );
  }
}
