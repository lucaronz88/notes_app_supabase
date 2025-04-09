import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notes_app_supabase/screens/edit_note_screen.dart';
import 'package:notes_app_supabase/screens/login_screen.dart';
import 'package:notes_app_supabase/screens/notes_screen.dart';
import 'package:notes_app_supabase/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:notes_app_supabase/screens/splash_screen.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Notes App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/notes': (context) => const NotesScreen(),
        '/edit_note': (context) => const EditNoteScreen(),
      },
    );
  }
}