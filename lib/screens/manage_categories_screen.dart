import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _controller = TextEditingController();

  void _addCategory() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).addCategory(name);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add Category',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final c = categories[index];
                  return ListTile(
                    title: Text(c.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.deleteCategory(c.id!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
