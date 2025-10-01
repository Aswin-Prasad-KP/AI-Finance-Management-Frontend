import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class ExpenseChart extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Filter for expenses only and group by category
    final expenseTransactions = transactions.where((tx) => tx.isExpense).toList();

    if (expenseTransactions.isEmpty) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline_rounded, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No expense data to display in chart.', style: GoogleFonts.poppins(color: Colors.grey.shade600))
            ],
          )
      );
    }

    final categorySpending = <String, double>{};
    for (var tx in expenseTransactions) {
      categorySpending.update(
        tx.category!.name,
            (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final totalSpending = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);

    final chartSections = categorySpending.entries.map((entry) {
      final percentage = (entry.value / totalSpending) * 100;
      final category = defaultCategories.firstWhere(
              (cat) => cat.name == entry.key,
          orElse: () => defaultCategories.last
      );

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: Colors.primaries[defaultCategories.indexOf(category) % Colors.primaries.length],
        radius: 80,
        titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: chartSections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

