import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(
              Icons.brightness_6_outlined,
              color: Colors.indigo,
            ),
            title: const Text('Theme Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup_outlined, color: Colors.indigo),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Export or import your data'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_none, color: Colors.indigo),
            title: const Text('Notifications'),
            subtitle: const Text('Set daily reminders to track expenses'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.indigo),
            title: const Text('About App'),
            subtitle: const Text('Version 1.0.0 • Made with Flutter ❤️'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
