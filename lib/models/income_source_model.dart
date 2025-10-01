import 'package:flutter/material.dart';

// Represents an income source with a name and an icon
class IncomeSource {
  final String name;
  final IconData icon;

  IncomeSource({required this.name, required this.icon});
}

// Pre-defined list of income sources for the user
final List<IncomeSource> defaultIncomeSources = [
  IncomeSource(name: 'Salary', icon: Icons.business_center_rounded),
  IncomeSource(name: 'Freelance', icon: Icons.work_outline_rounded),
  IncomeSource(name: 'Gifts', icon: Icons.card_giftcard_rounded),
  IncomeSource(name: 'Investment', icon: Icons.trending_up_rounded),
  IncomeSource(name: 'Rental', icon: Icons.house_rounded),
  IncomeSource(name: 'Other', icon: Icons.more_horiz_rounded),
];
