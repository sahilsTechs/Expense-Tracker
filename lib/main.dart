import 'package:expense_tracker/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/budget_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/category_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()..loadExpenses(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider()..loadBudget(),
        ), // ✅ this line required
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const MainScreen(),
      ),
    );
  }
}
