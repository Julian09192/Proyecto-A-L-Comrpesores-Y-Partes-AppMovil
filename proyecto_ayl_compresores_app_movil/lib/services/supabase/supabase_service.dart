import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static Future<void> initialize() async {

    final String supabaseUrl =
        dotenv.env['https://adaiklmjaoajsyixpvgc.supabase.co'] ?? '';
    final String supabaseAnonKey =
        dotenv
            .env['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkYWlrbG1qYW9hanN5aXhwdmdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MzkyMDAsImV4cCI6MjA5MzUxNTIwMH0.XG_N9KAcm0q4QjPl_LzEpRqL4wjyLP2vtklaA5PFvDk'] ??
        '';

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static final client = Supabase.instance.client;
}
