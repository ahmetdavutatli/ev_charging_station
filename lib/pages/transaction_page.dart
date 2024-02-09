import 'package:flutter/material.dart';
import '../models/transaction_model.dart'; // Import the Transaction model
import '../services/transaction_services.dart'; // Import the TransactionService

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TransactionService transactionService = TransactionService();
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  Future<void> fetchDataFromDatabase() async {
    List<Transaction> dataFromDatabase = (await transactionService.getTransactions()).cast<Transaction>();
    setState(() {
      transactions = dataFromDatabase;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        backgroundColor: Color(0xff26B6E1),
      ),
      body: transactions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionItem(transaction: transactions[index]);
        },
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.chargingStation),
      subtitle: Text(
        'Date: ${transaction.date} - Amount: \$${transaction.amount.toStringAsFixed(2)}',
      ),
      // Customize the appearance of each transaction item here
    );
  }
}
