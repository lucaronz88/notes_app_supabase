/*

AUTH GATE - This will continuously listen for auth state changes.
=================================================================

unauthenticated -> Login Page
authenticated   -> Home Page

*/

import 'package:flutter/material.dart';
import 'package:notes_app_supabase/pages/home_page.dart';
import 'package:notes_app_supabase/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      
      // Build appropriate page based on auth state
      builder: (context, snapshot) {
        // loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(),),
          );
        }

        //check if there's a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },);
  }
}