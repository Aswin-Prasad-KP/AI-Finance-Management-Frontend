import './category_model.dart';

class Budget {
  final String id;
  final ExpenseCategory category;
  final double amount;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
  });
}
