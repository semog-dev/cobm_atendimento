import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
