import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notes_app_supabase/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // ensure flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // load environment variables
  try {
    await dotenv.load(fileName: ".env");
  }
  // print errors if any
  catch (e) {
    throw Exception('Error loading .env file: $e');
  }

  // supabase setup
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
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
