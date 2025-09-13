import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color _selectedColor = Colors.blue;
  TimeOfDay _studyTime = const TimeOfDay(hour: 18, minute: 0);
  bool _notificationsEnabled = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
  final colorValue = prefs.getInt('themeColor') ?? Colors.blue.value;
    final hour = prefs.getInt('studyHour') ?? 18;
    final minute = prefs.getInt('studyMinute') ?? 0;
    final notif = prefs.getBool('notifications') ?? true;
    setState(() {
      _selectedColor = Color(colorValue);
      _studyTime = TimeOfDay(hour: hour, minute: minute);
      _notificationsEnabled = notif;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('studyHour', _studyTime.hour);
    await prefs.setInt('studyMinute', _studyTime.minute);
    await prefs.setBool('notifications', _notificationsEnabled);
    // Update theme color via provider
  Provider.of<ThemeProvider>(context, listen: false).setColor(_selectedColor);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!')));
  }

  Future<void> _pickColor() async {
    // Simple color picker dialog
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Theme Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            children: [
              Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal
            ].map((c) => GestureDetector(
              onTap: () => Navigator.pop(context, c),
              child: CircleAvatar(backgroundColor: c, radius: 20),
            )).toList(),
          ),
        ),
      ),
    );
    if (color != null) setState(() => _selectedColor = color);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _studyTime);
    if (picked != null) setState(() => _studyTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: const Text('Theme Color'),
                  trailing: CircleAvatar(backgroundColor: _selectedColor),
                  onTap: _pickColor,
                ),
                ListTile(
                  title: const Text('Study Time'),
                  trailing: Text(_studyTime.format(context)),
                  onTap: _pickTime,
                ),
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                  title: const Text('Enable Notifications'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Settings'),
                ),
              ],
            ),
    );
  }
}
