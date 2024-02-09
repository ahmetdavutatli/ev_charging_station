class Transaction {
  final String id; // Unique identifier for the transaction
  final String chargingStation;
  final String date;
  final double amount;

  Transaction({
    required this.id,
    required this.chargingStation,
    required this.date,
    required this.amount,
  });

  // Factory method to create a Transaction object from Firestore data
  factory Transaction.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Transaction(
      id: documentId,
      chargingStation: data['chargingStation'],
      date: data['date'],
      amount: data['amount'].toDouble(),
    );
  }
}