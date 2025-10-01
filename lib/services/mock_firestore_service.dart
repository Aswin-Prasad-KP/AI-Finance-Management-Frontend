import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/income_source_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_transaction_model.dart';

class MockFirestoreService {
  final _transactionsController = StreamController<List<Transaction>>.broadcast();
  final _budgetsController = StreamController<List<Budget>>.broadcast();
  final _criticalBudgetsController = StreamController<List<Budget>>.broadcast();
  final _recurringTransactionsController = StreamController<List<RecurringTransaction>>.broadcast();

  final List<Transaction> _mockTransactions = [
    Transaction(id: '1', amount: 4200.00, date: DateTime(2025, 9, 27), title: 'Zomato Order', isExpense: true, category: defaultCategories[0]),
    Transaction(id: '2', amount: 50000.00, date: DateTime(2025, 9, 26), title: 'September Salary', isExpense: false, incomeSource: defaultIncomeSources[0]),
    Transaction(id: '3', amount: 450.00, date: DateTime(2025, 9, 25), title: 'Movie Tickets', isExpense: true, category: defaultCategories[4]),
    Transaction(id: '4', amount: 7500.00, date: DateTime(2025, 9, 24), title: 'New Shoes', isExpense: true, category: defaultCategories[2]),
  ];

  final List<Budget> _mockBudgets = [
    Budget(id: 'food', category: defaultCategories[0], amount: 5000),
    Budget(id: 'shopping', category: defaultCategories[2], amount: 8000),
    Budget(id: 'entertainment', category: defaultCategories[4], amount: 3000),
  ];

  // Updated mock data with new fields
  final List<RecurringTransaction> _mockRecurring = [
    RecurringTransaction(id: 'rec1', title: 'Monthly Salary', amount: 50000, isExpense: false, frequency: 'Monthly', nextDate: DateTime(2025, 10, 1), neverEnds: true, incomeSource: defaultIncomeSources[0]),
    RecurringTransaction(id: 'rec2', title: 'Netflix Subscription', amount: 199, isExpense: true, frequency: 'Monthly', nextDate: DateTime(2025, 10, 5), neverEnds: true, category: defaultCategories[4]),
    RecurringTransaction(id: 'rec3', title: 'Bike EMI', amount: 4500, isExpense: true, frequency: 'Monthly', nextDate: DateTime(2025, 10, 10), endDate: DateTime(2026, 8, 10), category: defaultCategories[1]),
  ];

  MockFirestoreService() {
    _transactionsController.add(_mockTransactions);
    _budgetsController.add(_mockBudgets);
    _recurringTransactionsController.add(_mockRecurring);
    _calculateCriticalBudgets();
  }

  // Streams
  Stream<List<Transaction>> getTransactions() async* {
    yield _mockTransactions;
    yield* _transactionsController.stream;
  }
  Stream<List<Budget>> getBudgets() async* {
    yield _mockBudgets;
    yield* _budgetsController.stream;
  }
  Stream<List<RecurringTransaction>> getRecurringTransactions() async* {
    yield _mockRecurring;
    yield* _recurringTransactionsController.stream;
  }
  Stream<List<Budget>> getCriticalBudgets() async* {
    yield _getCriticalBudgets();
    yield* _criticalBudgetsController.stream;
  }

  // Methods
  Future<void> addTransaction(Transaction transaction) async {
    _mockTransactions.insert(0, transaction);
    _transactionsController.add(_mockTransactions);
    _calculateCriticalBudgets();
  }

  Future<void> addOrUpdateBudget(Budget budget) async {
    final index = _mockBudgets.indexWhere((b) => b.category.name == budget.category.name);
    if (index != -1) {
      _mockBudgets[index] = budget;
    } else {
      _mockBudgets.add(budget);
    }
    _budgetsController.add(_mockBudgets);
    _calculateCriticalBudgets();
  }

  // --- NEW METHOD ---
  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    _mockRecurring.add(transaction);
    _recurringTransactionsController.add(_mockRecurring);
  }


  // Helper methods
  void _calculateCriticalBudgets() {
    _criticalBudgetsController.add(_getCriticalBudgets());
  }
  List<Budget> _getCriticalBudgets() {
    return _mockBudgets.where((budget) {
      final spent = _getSpentForCategory(budget.category);
      return (spent / budget.amount) >= 0.8;
    }).toList();
  }
  double _getSpentForCategory(ExpenseCategory category) {
    return _mockTransactions
        .where((t) => t.isExpense && t.category?.name == category.name)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void dispose() {
    _transactionsController.close();
    _budgetsController.close();
    _criticalBudgetsController.close();
    _recurringTransactionsController.close();
  }
}

