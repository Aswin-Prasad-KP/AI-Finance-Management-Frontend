import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/transaction_model.dart';
import 'encryption_service.dart';

// This service handles all interactions with the Firestore database.
class FirestoreService {
  final String userId;
  final EncryptionService _encryptionService;
  late final CollectionReference _transactionsCollection;

  FirestoreService({required this.userId, required EncryptionService encryptionService})
      : _encryptionService = encryptionService {
    _transactionsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  // Add a new transaction to Firestore, encrypting the data first.
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final jsonMap = transaction.toJson();
      final jsonString = json.encode(jsonMap);
      final encryptedData = await _encryptionService.encryptData(jsonString);

      if (encryptedData != null) {
        await _transactionsCollection.add({
          'data': encryptedData,
          'date': transaction.date,
          'isExpense': transaction.isExpense,
        });
      }
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  // Get a stream of transactions, decrypting them in real-time.
  Stream<List<Transaction>> getTransactions() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final transactions = <Transaction>[];
      for (final doc in snapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>?;

        // FIX: This safety check prevents crashes from old/malformed data.
        if (docData != null && docData.containsKey('data')) {
          final encryptedPayload = docData['data'] as String?;
          if (encryptedPayload != null) {
            final decryptedString = await _encryptionService.decryptData(encryptedPayload);
            if (decryptedString != null) {
              final dataMap = json.decode(decryptedString) as Map<String, dynamic>;
              transactions.add(Transaction.fromFirestore(doc, dataMap));
            } else {
              transactions.add(Transaction.fromEncrypted(doc, encryptedPayload));
            }
          }
        }
        // If the document does not contain the 'data' field, it is safely ignored.
      }
      return transactions;
    });
  }
}

