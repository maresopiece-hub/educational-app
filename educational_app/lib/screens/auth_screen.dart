import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  void _showError(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError('Google sign-in failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignIn() async {
    setState(() => _isLoading = true);
    try {
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _showError('Enter a valid email');
        return;
      }
      if (_passwordController.text.length < 6) {
        _showError('Password must be at least 6 characters');
        return;
      }
      UserModel? user;
      if (_isLogin) {
        user = await AuthService().signInWithEmail(_emailController.text, _passwordController.text);
      } else {
        // Registration flow (ask for name, or use email prefix as fallback)
        String name = _emailController.text.split('@').first;
        user = await AuthService().registerWithEmail(_emailController.text, _passwordController.text, name);
      }
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError('Authentication failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 80),
                  const SizedBox(height: 24),
                  Text(
                    _isLogin ? 'Login to Continue' : 'Register New Account',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: Text(_isLogin ? 'Login' : 'Register'),
                    onPressed: _handleEmailSignIn,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Continue with Google'),
                    onPressed: _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? 'No account? Register' : 'Have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
