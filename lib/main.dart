import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notes_app_supabase/auth/auth_gate.dart';
import 'package:notes_app_supabase/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  }
  // Print errors if any
  catch (e) {
    throw Exception('Error loading .env file: $e');
  }

  // Supabase setup
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
