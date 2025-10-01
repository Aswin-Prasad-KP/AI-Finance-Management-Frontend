import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './category_model.dart';
import './income_source_model.dart';

// Represents a single financial transaction (either income or expense)
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;
  // A transaction can have an expense category OR an income source, but not both.
  final ExpenseCategory? category;
  final IncomeSource? incomeSource;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.category,
    this.incomeSource,
  }) : assert(isExpense ? category != null : incomeSource != null); // Ensures data integrity
}

