import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color _primaryColor = Colors.blue;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
    final colorString = prefs.getString('primaryColor');
    _primaryColor = colorString != null
      ? Color(int.parse(colorString, radix: 16))
      : Colors.blue;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Store color as full ARGB hex string so it can be parsed reliably.
  await prefs.setString('primaryColor', _primaryColor.toARGB32().toRadixString(16));
    await prefs.setBool('darkMode', _darkMode);
  }

  void _pickColor() async {
    Color? picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _primaryColor,
            onColorChanged: (color) => Navigator.of(context).pop(color),
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() => _primaryColor = picked);
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Primary Color'),
            trailing: CircleAvatar(backgroundColor: _primaryColor),
            onTap: _pickColor,
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
              _saveSettings();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              // TODO: Implement logout
            },
          ),
        ],
      ),
    );
  }
}

