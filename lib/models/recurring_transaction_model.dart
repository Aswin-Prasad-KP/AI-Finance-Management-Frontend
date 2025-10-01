import './category_model.dart';
import './income_source_model.dart';

// Represents a transaction that occurs on a regular schedule
class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String frequency; // e.g., "Monthly", "Weekly"
  final DateTime nextDate;
  // --- NEW FIELDS ---
  final DateTime? endDate; // Nullable for transactions that never end
  final bool neverEnds;

  // Link to a category or income source
  final ExpenseCategory? category;
  final IncomeSource? incomeSource;

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.frequency,
    required this.nextDate,
    this.endDate,
    this.neverEnds = false,
    this.category,
    this.incomeSource,
  }) : assert(isExpense ? category != null : incomeSource != null);
}

