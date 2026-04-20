import 'package:adv_basic/features/auth/services/auth_service.dart';
import 'package:adv_basic/main_navigation_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(email: email, password: password);
      if (!mounted) return;
      final user = result['user'];

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Welcome, ${user.name}!')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                Text("Email"),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("Password"),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text("Login"),
            ),
            Row(
              children: [
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // Handle sign-up logic here
                  },
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
