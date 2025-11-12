import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;

    if (expenses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard & Insights'),
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'No data available yet.\nAdd some expenses to see your insights!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final totalSpent = provider.totalAmount;
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    // Sort by most spent
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategories.isNotEmpty
        ? sortedCategories.first.key
        : "N/A";
    final topCategoryAmount = sortedCategories.isNotEmpty
        ? sortedCategories.first.value
        : 0.0;

    // Group by day (for bar chart)
    final Map<String, double> dailyTotals = {};
    for (var e in expenses) {
      final day = DateFormat('MMM dd').format(e.date);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + e.amount;
    }

    final avgDaily = totalSpent / dailyTotals.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dashboard & Insights',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 💎 Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard(
                  title: 'Total Spent',
                  value: '₹${totalSpent.toStringAsFixed(2)}',
                  icon: Icons.wallet_rounded,
                  color: Colors.indigo,
                ),
                _summaryCard(
                  title: 'Top Category',
                  value: topCategory,
                  icon: Icons.category,
                  color: Colors.orangeAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _summaryCard(
              title: 'Avg per Day',
              value: '₹${avgDaily.toStringAsFixed(2)}',
              icon: Icons.calendar_today_outlined,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            // 📈 Pie Chart (By Category)
            _chartCard(
              title: 'Spending by Category',
              child: SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((entry) {
                      final percent = (entry.value / totalSpent) * 100;
                      return PieChartSectionData(
                        color:
                            Colors.primaries[entry.key.hashCode %
                                Colors.primaries.length],
                        value: entry.value,
                        title: '${entry.key}\n${percent.toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📉 Bar Chart (By Day)
            _chartCard(
              title: 'Spending by Day',
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final dayIndex = value.toInt();
                            if (dayIndex >= 0 &&
                                dayIndex < dailyTotals.keys.length) {
                              return Text(
                                dailyTotals.keys.elementAt(dayIndex),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: List.generate(dailyTotals.length, (i) {
                      final amount = dailyTotals.values.elementAt(i);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: amount,
                            color: Colors.indigo,
                            width: 16,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🧠 Smart Insights
            _insightCard(
              topCategory: topCategory,
              percent: (topCategoryAmount / totalSpent) * 100,
              totalSpent: totalSpent,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Summary Card Widget
  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 160,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Chart Card Wrapper
  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // 🔹 Insights Card
  Widget _insightCard({
    required String topCategory,
    required double percent,
    required double totalSpent,
  }) {
    String message;

    if (percent >= 50) {
      message =
          '⚠️ Most of your spending (${percent.toStringAsFixed(1)}%) is on $topCategory. Consider reducing it next month.';
    } else if (percent >= 25) {
      message =
          '💡 $topCategory takes ${percent.toStringAsFixed(1)}% of your total spending — that’s quite balanced!';
    } else {
      message =
          '🎉 Great! Your spending is well distributed — only ${percent.toStringAsFixed(1)}% on $topCategory.';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }
}
