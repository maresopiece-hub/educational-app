import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final user = await db.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      } else {
        setState(() {
          _error = 'Invalid email or password.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final user = await db.registerUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      } else {
        setState(() {
          _error = 'Registration failed.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Registration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email.';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
                          ),
                          OutlinedButton(
                            onPressed: _register,
                            child: const Text('Register'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
