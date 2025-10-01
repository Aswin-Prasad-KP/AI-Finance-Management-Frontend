import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart' as app;
import '../services/firestore_service.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsScreen extends StatelessWidget {
  final bool isPushed;
  const TransactionsScreen({super.key, this.isPushed = false});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: isPushed, // Show back button only if pushed
      ),
      body: StreamBuilder<List<app.Transaction>>(
        stream: firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No transactions found.',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            );
          }
          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TransactionListItem(transaction: transactions[index]);
            },
          );
        },
      ),
    );
  }
}
