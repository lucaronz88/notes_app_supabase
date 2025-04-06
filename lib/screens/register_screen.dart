import 'package:flutter/material.dart';
import 'package:notes_app_supabase/components/my_button.dart';
import 'package:notes_app_supabase/components/my_textformfield.dart';
import 'package:notes_app_supabase/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // get auth service
  final AuthService _authService = AuthService();

  // form variables
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // to track if async op is currently in progress
  bool _isLoading = false;

  // error message
  String? _errorMessage;

  // validator for email
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Please enter your email";
    }
    if (!email.contains("@")) {
      return "Please enter a valid email";
    }
    return null;
  }

  // validator for password
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Please enter your password";
    }
    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  // confirm if password match
  String? confirmPassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Please confirm your password";
    }
    if (password != _passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  // login method
  Future<void> _signUp() async {
    // validate the email and password
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // try to sign in
      try {
        await _authService.signUpWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: 
          Text("Registration successful!"))
        );
        Navigator.of(context).pushReplacementNamed('/notes');
      }
      // catch any errors
      catch (e) {
        setState(() {
          _errorMessage = "Failed to sign up: ${e.toString()}";
        });
      }
      // update the loading state
      finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            const Icon(Icons.note_alt_outlined, size: 100, color: Colors.grey),

            const SizedBox(height: 40),

            // welcome text
            Text(
              "Please fill your info to register",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),

            const SizedBox(height: 16),

            // email textfield
            MyTextFormField(
              controller: _emailController,
              labelText: "Email",
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              validator: (email) => validateEmail(email),
            ),

            const SizedBox(height: 16),

            // password textfield
            MyTextFormField(
              controller: _passwordController,
              labelText: "Password",
              obscureText: true,
              validator: (password) => validatePassword(password),
            ),

            const SizedBox(height: 16),

            // confirm password textfield
            MyTextFormField(
              controller: _confirmPasswordController,
              labelText: "Confirm Password",
              obscureText: true,
              validator: (password) => confirmPassword(password),
            ),

            const SizedBox(height: 16),

            // show error message if any
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24, bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Sign in button
            MyButton(
              onTap: _isLoading ? null : _signUp,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
            ),

            const SizedBox(height: 16),

            // navigate to register page
            TextButton(
              onPressed:
                  () => Navigator.of(context).pushReplacementNamed('/login'),
              child: const Text("Already have an account? Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}