import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/utils/export_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: Colors.indigo),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
              activeColor: Colors.indigo,
            ),
          ),

          const Divider(height: 40),
          const Text(
            'Data Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Export CSV
          ListTile(
            leading: const Icon(
              Icons.file_present_outlined,
              color: Colors.green,
            ),
            title: const Text('Export to CSV'),
            subtitle: const Text(
              'Download or share your expenses as a .csv file',
            ),
            onTap: () => ExportUtils.exportToCsv(expenseProvider.expenses),
          ),

          // Export JSON
          ListTile(
            leading: const Icon(Icons.code_outlined, color: Colors.orange),
            title: const Text('Export to JSON'),
            subtitle: const Text(
              'Download or share your expenses as a .json file',
            ),
            onTap: () => ExportUtils.exportToJson(expenseProvider.expenses),
          ),

          const Divider(height: 40),
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.indigo),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.indigo),
            title: const Text('Developed by Sahil Rathod'),
          ),
        ],
      ),
    );
  }
}
