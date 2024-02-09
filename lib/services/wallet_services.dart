import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';
import '../auth.dart';

class WalletService {
  final Auth auth;
  late WalletModel _walletModel;

  WalletService({required this.auth}) {
    _walletModel = WalletModel(balance: 0.0);
    _loadBalanceFromFirestore(); // Load the balance from Firestore during initialization
  }

  Future<void> _loadBalanceFromFirestore() async {
    try {
      // Get the current user's document from Firestore
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.user?.uid)
          .get();

      // Set the initial balance in _walletModel
      _walletModel = WalletModel(
        balance: (userDocument['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      // Handle error
      print('Error loading wallet balance from Firestore: $e');
    }
  }

  // Method to get the balance
  Future<double> getBalance() async {
    try {
      // Reload the balance from Firestore before returning
      await _loadBalanceFromFirestore();

      // Return the current balance
      return _walletModel.getBalance();
    } catch (e) {
      // Handle error
      print('Error getting wallet balance: $e');
      return 0.0;
    }
  }

  // Method to add funds
  void addFunds(double amount) {
    _walletModel.addFunds(amount);

    // Update the balance in Firestore
    _updateBalanceInFirestore();
  }

  // Update the balance in Firestore
  Future<void> _updateBalanceInFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.user?.uid)
          .update({'wallet_balance': _walletModel.getBalance()});
    } catch (e) {
      print('Error updating wallet balance in Firestore: $e');
    }
  }
}

