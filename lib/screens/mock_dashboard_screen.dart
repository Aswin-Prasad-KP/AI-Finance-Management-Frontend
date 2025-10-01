import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/budget_model.dart';
import 'mock_main_screen.dart';

import '../models/transaction_model.dart';
import '../services/mock_firestore_service.dart';
import '../widgets/mock_expense_chart.dart';
import '../widgets/transaction_list_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<MockFirestoreService>(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }

          final transactions = snapshot.data!;
          final totalExpense = transactions
              .where((t) => t.isExpense)
              .fold(0.0, (sum, item) => sum + item.amount);
          final totalIncome = transactions
              .where((t) => !t.isExpense)
              .fold(0.0, (sum, item) => sum + item.amount);
          final balance = totalIncome - totalExpense;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              _buildBalanceCard(context, currencyFormat.format(balance), currencyFormat.format(totalIncome), currencyFormat.format(totalExpense)),
              const SizedBox(height: 24),
              _buildCriticalBudgetsSection(firestoreService, currencyFormat),
              const SizedBox(height: 24),
              Text('Spending Categories', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ExpenseChart(transactions: transactions),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              ...transactions.take(3).map((tx) => TransactionListItem(transaction: tx)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCriticalBudgetsSection(MockFirestoreService firestoreService, NumberFormat currencyFormat) {
    return StreamBuilder<List<Budget>>(
      stream: firestoreService.getCriticalBudgets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final criticalBudgets = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Critical Budgets', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
            const SizedBox(height: 8),
            ...criticalBudgets.map((budget) => _buildCriticalBudgetCard(context, budget, firestoreService, currencyFormat)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildCriticalBudgetCard(BuildContext context, Budget budget, MockFirestoreService firestoreService, NumberFormat currencyFormat) {
    return StreamBuilder<List<Transaction>>(
      stream: firestoreService.getTransactions(),
      builder: (context, transactionSnapshot) {
        if (!transactionSnapshot.hasData) return const SizedBox.shrink();
        final spent = transactionSnapshot.data!
        // THE FIX: Using the null-aware operator (?.) to safely access 'name'
            .where((t) => t.isExpense && t.category?.name == budget.category.name)
            .fold(0.0, (sum, item) => sum + item.amount);

        return Card(
          elevation: 0,
          color: Colors.red.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            title: Text('${budget.category.name} Budget Alert', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            subtitle: Text('Spent ${currencyFormat.format(spent)} of ${currencyFormat.format(budget.amount)}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              mainScreenKey.currentState?.changeTab(2);
            },
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, String balance, String income, String expense) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              balance,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIncomeExpenseRow(Icons.arrow_downward, 'Income', income, Colors.greenAccent),
                _buildIncomeExpenseRow(Icons.arrow_upward, 'Expense', expense, Colors.redAccent),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseRow(IconData icon, String title, String amount, Color color) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            Text(
              amount,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

