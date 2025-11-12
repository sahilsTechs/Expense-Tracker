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

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final expenses = expenseProvider.expenses;
    final filtered = _filter == 'All'
        ? expenses
        : expenses.where((e) => e.category == _filter).toList();

    final currencyFormatter = NumberFormat.simpleCurrency();
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: true);

    final totalSpent = expenseProvider.totalAmount;
    final budget = budgetProvider.budgetLimit;
    final remaining = (budget - totalSpent).clamp(0, double.infinity);
    final progress = (budget == 0) ? 0 : (totalSpent / budget).clamp(0, 1);
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
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                ),
              );
              setState(() {}); // refresh categories on return
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
              setState(() {}); // ✅ rebuild after coming back
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 💰 Summary Card
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
            child: Row(
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
                  currencyFormatter.format(expenseProvider.totalAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Consumer<BudgetProvider>(
            builder: (context, budgetProvider, _) {
              final expenseProvider = Provider.of<ExpenseProvider>(
                context,
                listen: false,
              );
              final totalSpent = expenseProvider.totalAmount;
              final budget = budgetProvider.budgetLimit;
              final remaining = (budget - totalSpent).clamp(0, double.infinity);
              final double progress = (budget == 0)
                  ? 0.0
                  : (totalSpent / budget).clamp(0.0, 1.0);

              return Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "This Month's Budget",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SetBudgetScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      budget == 0
                          ? 'No budget set'
                          : '₹${budget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
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
                        color: progress >= 1
                            ? Colors.redAccent
                            : Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🏷 Category Chips
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildCategoryChips(categoryProvider),
          ),

          // 📜 Expense List or Empty State
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

  // 💡 Redesigned Category Chips Section
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

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: ChoiceChip(
              elevation: selected ? 4 : 0,
              pressElevation: 4,
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
              side: BorderSide(
                color: selected ? Colors.indigo : Colors.grey[300]!,
              ),
              onSelected: (_) => setState(() => _filter = c),
            ),
          );
        },
      ),
    );
  }

  // 🎭 Empty State
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
              'No expenses yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start tracking your spending by adding an expense.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
