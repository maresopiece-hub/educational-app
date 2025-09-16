import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firebase_auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool get _showGoogleSignIn => kIsWeb || Platform.isAndroid || Platform.isIOS;
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Name field not needed for Firebase Auth
  bool _loading = false;
  String? _error;

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      _error = null;
    });
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final navigator = Navigator.of(context);
    bool success = false;
    try {
      final auth = AuthService();
      if (isLogin) {
        await auth.signInWithEmail(_emailController.text, _passwordController.text);
      } else {
        await auth.registerWithEmail(_emailController.text, _passwordController.text);
      }
      success = true;
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) {
        setState(() { _loading = false; });
        if (success) {
          navigator.pushReplacementNamed('/');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: Text(isLogin ? 'Login' : 'Sign Up'),
                  ),
            if (_showGoogleSignIn)
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
                onPressed: () async {
                  setState(() { _loading = true; _error = null; });
                  bool success = false;
                  final navigator = Navigator.of(context);
                  try {
                    await AuthService().signInWithGoogle();
                    success = true;
                  } catch (e) {
                    setState(() { _error = e.toString(); });
                  } finally {
                    if (mounted) {
                      setState(() { _loading = false; });
                      if (success) {
                        navigator.pushReplacementNamed('/');
                      }
                    }
                  }
                },
              ),
            TextButton(
              onPressed: _toggleMode,
              child: Text(isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                if (_emailController.text.isEmpty) {
                  setState(() { _error = 'Enter your email to reset password.'; });
                  return;
                }
                setState(() { _loading = true; _error = null; });
                try {
                  await AuthService().sendPasswordResetEmail(_emailController.text);
                  setState(() { _error = 'Password reset email sent!'; });
                } catch (e) {
                  setState(() { _error = e.toString(); });
                } finally {
                  setState(() { _loading = false; });
                }
              },
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
