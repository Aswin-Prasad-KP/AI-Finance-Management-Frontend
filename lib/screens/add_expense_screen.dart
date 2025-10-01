import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';

enum TransactionType { expense, income }

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory? _selectedCategory;
  TransactionType _transactionType = TransactionType.expense;

  Future<void> _submitData() async {
    final firestoreService = Provider.of<FirestoreService?>(context, listen: false);
    if (firestoreService == null || _amountController.text.isEmpty || _selectedCategory == null) {
      return;
    }

    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      return;
    }

    final newTransaction = Transaction(
      id: '', // Firestore will generate this
      title: _titleController.text.isEmpty ? _selectedCategory!.name : _titleController.text,
      amount: enteredAmount,
      date: _selectedDate,
      category: _selectedCategory!,
      isExpense: _transactionType == TransactionType.expense,
    );

    await firestoreService.addTransaction(newTransaction);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CupertinoSlidingSegmentedControl<TransactionType>(
              groupValue: _transactionType,
              backgroundColor: Colors.grey.shade200,
              thumbColor: _transactionType == TransactionType.expense ? Colors.red.shade400 : Colors.green.shade400,
              onValueChanged: (value) {
                if (value != null) {
                  setState(() {
                    _transactionType = value;
                  });
                }
              },
              children: {
                TransactionType.expense: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Expense', style: GoogleFonts.poppins(color: _transactionType == TransactionType.expense ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                ),
                TransactionType.income: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Income', style: GoogleFonts.poppins(color: _transactionType == TransactionType.income ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                ),
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _amountController,
              hintText: 'Amount',
              icon: Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _titleController,
              hintText: 'Title (Optional)',
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 20),
            Text('Select Category', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: defaultCategories.map((category) {
                final isSelected = _selectedCategory?.name == category.name;
                return ChoiceChip(
                  label: Text(category.name),
                  avatar: Icon(category.icon, color: isSelected ? Colors.white : Theme.of(context).primaryColor),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Text('Date: ${MaterialLocalizations.of(context).formatShortDate(_selectedDate)}')),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Choose Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

