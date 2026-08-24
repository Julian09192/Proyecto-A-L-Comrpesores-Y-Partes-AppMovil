import 'package:supabase_flutter/supabase_flutter.dart';
class SupabaseService {
  static const String _supabaseUrl = 'https://adaiklmjaoajsyixpvgc.supabase.co';

  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkYWlrbG1qYW9hanN5aXhwdmdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MzkyMDAsImV4cCI6MjA5MzUxNTIwMH0.XG_N9KAcm0q4QjPl_LzEpRqL4wjyLP2vtklaA5PFvDk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}