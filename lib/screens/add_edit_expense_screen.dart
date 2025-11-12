import 'package:expense_tracker/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  String _category = Constants.categories.first;
  DateTime _date = DateTime.now();
  String? _notes;

  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final e = widget.expense!;
      _title = e.title;
      _amount = e.amount;
      _amountController.text = e.amount.toString();
      _category = e.category;
      _date = e.date;
      _notes = e.notes;
    } else {
      _title = '';
      _amount = 0.0;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    final expense = Expense(
      id: widget.expense?.id,
      title: _title,
      amount: _amount,
      category: _category,
      date: _date,
      notes: _notes,
    );

    if (widget.expense == null) {
      await provider.addExpense(expense);
    } else {
      await provider.updateExpense(expense);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categoryNames = categoryProvider.categories
        .map((e) => e.name)
        .toList();
    if (!categoryNames.contains(_category) && categoryNames.isNotEmpty) {
      _category = categoryNames.first;
    }
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Expense' : 'Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  final parsed = double.tryParse(v);
                  if (parsed == null || parsed <= 0) return 'Invalid amount';
                  return null;
                },
                onSaved: (v) => _amount = double.parse(v!.trim()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: categoryNames
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_date)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
                onSaved: (v) => _notes = v?.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
