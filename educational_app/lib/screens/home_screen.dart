import 'package:flutter/material.dart';
import '../widgets/progress_widget.dart';
import '../widgets/motivational_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _lastStreak = 0;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _user = args;
        _isLoading = false;
      });
    } else {
      // Try to load from DB (for demo, just set loading false)
      setState(() {
        _isLoading = false;
      });
    }
    // Demo: Show motivational popup if streak increases
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      // In real app, fetch streak from DB and compare
      int currentStreak = 7; // Example
      if (currentStreak > _lastStreak) {
        _lastStreak = currentStreak;
        showDialog(
          context: context,
          builder: (ctx) => const MotivationalPopup(
            message: 'Great job! Streak up! 🎉',
            animationAsset: 'assets/lottie/confetti.flr',
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_user?['name'] ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ProgressWidget(userId: _user?['id'] ?? 'demo_user'),
                  const SizedBox(height: 24),
                  _buildNavButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildNavButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _navButton('Upload', Icons.upload_file, '/upload'),
        _navButton('Study', Icons.flash_on, '/flashcards'),
        _navButton('Exam', Icons.quiz, '/exam'),
      ],
    );
  }

  Widget _navButton(String label, IconData icon, String route) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
    );
  }
}
