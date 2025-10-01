import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction_model.dart';

class ExpenseChart extends StatefulWidget {
  final List<Transaction> transactions;
  const ExpenseChart({super.key, required this.transactions});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expenseTransactions = widget.transactions.where((tx) => tx.isExpense).toList();
    final spendingByCategory = <String, double>{};

    for (var tx in expenseTransactions) {
      // THE FIX: Using the null-aware operator (?.) to safely access 'name'
      // and a null-check to ensure we don't process transactions without a category
      if (tx.category != null) {
        spendingByCategory.update(
          tx.category!.name,
              (value) => value + tx.amount,
          ifAbsent: () => tx.amount,
        );
      }
    }

    final totalSpending = spendingByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    if (totalSpending == 0) {
      return Center(
        child: Text('No expense data for chart.', style: GoogleFonts.poppins()),
      );
    }

    final chartData = spendingByCategory.entries.map((entry) {
      final percentage = (entry.value / totalSpending) * 100;
      return PieChartSectionData(
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: touchedIndex == spendingByCategory.keys.toList().indexOf(entry.key) ? 60 : 50,
        titleStyle: GoogleFonts.poppins(
          fontSize: touchedIndex == spendingByCategory.keys.toList().indexOf(entry.key) ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        // Simple color generation based on hash code
        color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
      );
    }).toList();

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: chartData,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

