import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_charging_station/models/transaction_model.dart' as MyTransaction;

class TransactionService {
  final CollectionReference transactionsCollection =
  FirebaseFirestore.instance.collection('transactions');

  // Fetch all transactions from Firestore
  Future<List<MyTransaction.Transaction>> getTransactions() async {
    try {
      QuerySnapshot querySnapshot = await transactionsCollection.get();
      return querySnapshot.docs
          .map((doc) => MyTransaction.Transaction.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }
}