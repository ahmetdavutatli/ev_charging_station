import 'package:flutter/material.dart';
import '../auth.dart';
import '../services/wallet_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletPage extends StatefulWidget {
  final Auth auth;
  final WalletService walletService;

  const WalletPage({Key? key, required this.auth, required this.walletService}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double usdToEurRate = 0.92;
  double usdToTryRate = 13.5;
  double usdToBtcRate = 0.000022;
  String selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 60, width: 60),
      ),
      backgroundColor: const Color(0xff262930),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<double>(
              future: _loadUsdBalance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('${AppLocalizations.of(context)!.error}: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
                } else {
                  double usdBalance = snapshot.data ?? 0.0;
                  return _buildBalanceDisplay(usdBalance);
                }
              },
            ),
            const SizedBox(height: 20),
            _buildAddFundsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDisplay(double usdBalance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainBalanceRow('USD', usdBalance, Icons.attach_money, 30.0),
        const SizedBox(height: 8),
        _buildSecondaryBalance('EUR', usdBalance * usdToEurRate, Icons.euro_symbol),
        _buildSecondaryBalance('TRY', usdBalance * usdToTryRate, Icons.currency_lira),
        _buildSecondaryBalance('BTC', usdBalance * usdToBtcRate, Icons.currency_bitcoin),
      ],
    );
  }

  Widget _buildMainBalanceRow(String currency, double balance, IconData iconData, double iconSize) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25.0,
        backgroundColor: Colors.green,
        child: Icon(iconData, size: iconSize, color: Colors.white),
      ),
      title: Text(
        '$currency: \$${balance.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildSecondaryBalance(String currency, double balance, IconData iconData) {
    String formattedBalance = currency == 'BTC'
        ? balance.toStringAsFixed(8)
        : balance.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(iconData, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            '$currency: \$${formattedBalance}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFundsButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.green,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: () => _showAddFundsDialog(context),
      child: Text(AppLocalizations.of(context)!.addFunds),
    );
  }

  Future<double> _loadUsdBalance() async {
    if (widget.auth.user != null) {
      try {
        return await widget.walletService.getBalance();
      } catch (e) {
        print('Error loading balance: $e');
        return 0.0;
      }
    } else {
      return 0.0; // Kullanıcı giriş yapmamışsa 0 döndür
    }
  }

  void _showAddFundsDialog(BuildContext context) {
    double amountToAdd = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addFunds),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCurrency,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCurrency = newValue!;
                  });
                },
                items: <String>['USD', 'EUR', 'TRY', 'BTC']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amountToAdd = _convertToUsd(double.tryParse(value) ?? 0.0);
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                  labelStyle: TextStyle(color: Color(0xff262930)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff262930)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xff262930)),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.walletService.addFunds(amountToAdd);
                  setState(() {});
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff26B6E1),

                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                child: Text(AppLocalizations.of(context)!.addFunds, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }

  double _convertToUsd(double amount) {
    switch (selectedCurrency) {
      case 'EUR':
        return amount / usdToEurRate;
      case 'TRY':
        return amount / usdToTryRate;
      case 'BTC':
        return amount / usdToBtcRate;
      default:
        return amount; // Default to USD
    }
  }
}