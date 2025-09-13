import 'package:flutter/material.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example streak, badges, and confetti UI
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements & Streaks')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
                const SizedBox(width: 8),
                Text('7-day streak!', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Badges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _badge('Quiz Master', Icons.emoji_events, Colors.amber),
                _badge('Flashcard Pro', Icons.style, Colors.blue),
                _badge('Streak Star', Icons.star, Colors.orange),
                _badge('Plan Creator', Icons.edit, Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Trigger confetti animation
              },
              child: const Text('Celebrate!'),
            ),
            const SizedBox(height: 32),
            const Text('Notifications and reminders will appear here.'),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withAlpha((0.2 * 255).toInt()),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
