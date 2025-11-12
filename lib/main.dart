import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:expense_tracker/providers/category_provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()..loadExpenses(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..loadBudget()),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[900],
      ),
      home: const MainScreen(),
    );
  }
}
