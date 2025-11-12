import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:expense_tracker/providers/category_provider.dart';
import 'package:expense_tracker/screens/manage_categories_screen.dart';
import 'package:expense_tracker/screens/set_budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../screens/add_edit_expense_screen.dart';
import '../widgets/expense_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'All';
  DateTimeRange? _selectedRange;
  String _searchQuery = '';
  String _sortOption = 'Newest First'; // default sort

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: true);
    final currencyFormatter = NumberFormat.simpleCurrency();

    // Filtered expenses (category + date + search)
    List filtered = List.from(
      _filter == 'All'
          ? expenseProvider.expenses
          : expenseProvider.expenses.where((e) => e.category == _filter),
    );

    // Apply date range filter
    if (_selectedRange != null) {
      filtered = filtered.where((e) {
        return e.date.isAfter(
              _selectedRange!.start.subtract(const Duration(days: 1)),
            ) &&
            e.date.isBefore(_selectedRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) {
        final q = _searchQuery.toLowerCase();
        return e.title.toLowerCase().contains(q) ||
            e.note.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q);
      }).toList();
    }

    // ✅ Apply sorting
    switch (_sortOption) {
      case 'Newest First':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest First':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Amount: High → Low':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Amount: Low → High':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    final totalSpent = filtered.fold<double>(0, (sum, e) => sum + e.amount);
    final budget = budgetProvider.budgetLimit;
    final remaining = (budget - totalSpent).clamp(0, double.infinity);
    final double progress = (budget == 0)
        ? 0
        : (totalSpent / budget).clamp(0, 1);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            tooltip: 'Filter by Date Range',
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 1),
                initialDateRange:
                    _selectedRange ??
                    DateTimeRange(
                      start: DateTime(now.year, now.month, 1),
                      end: now,
                    ),
              );
              if (picked != null) setState(() => _selectedRange = picked);
            },
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                ),
              );
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Set Budget',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetBudgetScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 💰 Budget Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(totalSpent),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: progress >= 1
                      ? Colors.redAccent
                      : progress >= 0.75
                      ? Colors.orangeAccent
                      : Colors.greenAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 8),
                Text(
                  budget == 0
                      ? 'Set a budget to track progress'
                      : progress >= 1
                      ? '⚠️ You have exceeded your budget!'
                      : 'Remaining: ₹${remaining.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // 📆 Show Selected Date Range
          if (_selectedRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(_selectedRange!.start)} → ${DateFormat('MMM dd, yyyy').format(_selectedRange!.end)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedRange = null),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
            ),

          // 🔍 Search + Sort Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _sortOption,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    icon: const Icon(Icons.sort, color: Colors.indigo),
                    items: const [
                      DropdownMenuItem(
                        value: 'Newest First',
                        child: Text('Newest'),
                      ),
                      DropdownMenuItem(
                        value: 'Oldest First',
                        child: Text('Oldest'),
                      ),
                      DropdownMenuItem(
                        value: 'Amount: High → Low',
                        child: Text('High → Low'),
                      ),
                      DropdownMenuItem(
                        value: 'Amount: Low → High',
                        child: Text('Low → High'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _sortOption = value!);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🏷 Category Chips
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildCategoryChips(categoryProvider),
          ),

          // 📜 Expense List
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    color: Colors.indigo,
                    onRefresh: () => expenseProvider.loadExpenses(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ExpenseTile(expense: item);
                      },
                    ),
                  ),
          ),
        ],
      ),

      // ➕ Floating Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
          );
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildCategoryChips(CategoryProvider categoryProvider) {
    final categoryList = categoryProvider.categories
        .map((e) => e.name)
        .toList();
    final cats = ['All', ...categoryList];

    if (categoryList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = cats[i];
          final selected = c == _filter;
          return ChoiceChip(
            label: Text(
              c,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            selected: selected,
            selectedColor: Colors.indigo,
            backgroundColor: Colors.white,
            onSelected: (_) => setState(() => _filter = c),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wallet_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No expenses found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing filters or adding an expense.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
