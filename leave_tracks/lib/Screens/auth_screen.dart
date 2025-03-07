import 'package:flutter/material.dart';
import '../Service/auth_service.dart';
import '../Widgets/auth_button.dart';
import '../Widgets/text_field.dart';
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin)
              CustomTextField(
                controller: _usernameController,
                label: 'Username',
              ),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
            ),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            AuthButton(
              text: _isLogin ? 'Login' : 'Register',
              onPressed: () async {
                try {
                  if (_isLogin) {
                    await _authService.signInWithEmail(
                      _emailController.text,
                      _passwordController.text,
                    );
                  } else {
                    await _authService.registerWithEmail(
                      _emailController.text,
                      _passwordController.text,
                      _usernameController.text,
                    );
                  }
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            AuthButton(
              text: 'Sign in with Google',
              onPressed: () async {
                try {
                  await _authService.signInWithGoogle();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              isGoogle: true,
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? 'Need an account?' : 'Already have an account?'),
            ),
          ],
        ),
      ),
    );
  }
}