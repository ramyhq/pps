import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://xgzrkvbsokkocvwiwnib.supabase.co',
);
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnenJrdmJzb2trb2N2d2l3bmliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzMTI1OTcsImV4cCI6MjA4ODg4ODU5N30.d4dxFd7cysm2YHAPyLAEXAHz1nuKCUkgcDyoUHtATGk',
);

bool get isSupabaseConfigured =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

Future<void> initializeSupabase() async {
  if (!isSupabaseConfigured) {
    return;
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!isSupabaseConfigured) {
    return null;
  }
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});
