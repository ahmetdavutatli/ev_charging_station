import 'package:flutter/material.dart';
import '../auth.dart';
import '../services/wallet_services.dart';

class WalletPage extends StatefulWidget {
  final Auth auth;
  final WalletService walletService;

  const WalletPage({Key? key, required this.auth, required this.walletService}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        backgroundColor: const Color(0xff26B6E1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display current balance
            FutureBuilder<double>(
              future: _loadBalance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // If the Future is still running, show a loading indicator
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If the Future completes with an error, display the error message
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If the Future is complete, display the current balance
                  double currentBalance = snapshot.data ?? 0.0;
                  return Text(
                    'Current Balance: \$${currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            // Button to add funds
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff26B6E1),
              ),
              onPressed: () {
                // Show a dialog or navigate to a page where the user can input the amount to add
                _showAddFundsDialog(context);
              },
              child: Text('Add Funds'),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _loadBalance() async {
    if (widget.auth.user != null) {
      return await widget.walletService.getBalance();
    } else {
      // Handle the case where the user is not authenticated
      // You might want to show a login screen or redirect to the login page
      return 0.0;
    }
  }

  void _showAddFundsDialog(BuildContext context) {
    double amountToAdd = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Funds'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amountToAdd = double.tryParse(value) ?? 0.0;
                },
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add funds and update the UI
                  widget.walletService.addFunds(amountToAdd);
                  setState(() {});
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}
