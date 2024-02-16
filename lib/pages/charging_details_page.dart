import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/station_model.dart';
import '../selected_car.dart';
import '../auth.dart';

class ChargingDetailsPage extends StatefulWidget {
  final Station station;

  ChargingDetailsPage({required this.station});

  @override
  _ChargingDetailsPageState createState() => _ChargingDetailsPageState();
}

class _ChargingDetailsPageState extends State<ChargingDetailsPage> {
  late Timer _chargingTimer;
  int remainingCharge = 0;
  bool isChargingStopped = false;
  bool isUpdatingCharge = false;
  double walletBalance = 0;
  double fee = 1.2;

  @override
  void initState() {
    super.initState();

    // Fetch user's wallet balance from Firebase
    fetchWalletBalance();

    // Initialize the timer without starting it
    _chargingTimer = Timer(Duration.zero, () {});

    // Start charging process when the page is first loaded
    startCharging();
  }

  void fetchWalletBalance() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DocumentSnapshot walletSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (walletSnapshot.exists) {
        final walletData = walletSnapshot.data() as Map<String, dynamic>?;

        if (walletData != null && walletData.containsKey('wallet_balance')) {
          setState(() {
            walletBalance = walletData['wallet_balance'].toDouble();
          });
        }
      }
    }
  }

  void startCharging() {
    // Clear any existing timer
    _chargingTimer.cancel();

    // Initialize the timer to simulate the charging process
    const chargingInterval = const Duration(seconds: 5);
    _chargingTimer = Timer.periodic(chargingInterval, (timer) {
      // Increment the remaining charge for the selected car
      if (!isChargingStopped) {
        increaseRemainingCharge();
      }
    });
  }

  void stopCharging() {
    setState(() {
      isChargingStopped = true;
    });

    // Calculate charging cost and deduct from wallet balance
    calculateAndDeductCost();
  }

  void resumeCharging() {
    setState(() {
      isChargingStopped = false;
    });

    // Resume charging process
    startCharging();
  }

  void calculateAndDeductCost() async {
    // Calculate charging cost based on station's fee and time passed
    double chargingCost = (fee * (_chargingTimer.tick ~/ 5)); // Assuming fee is per 5 seconds

    // Deduct charging cost from wallet balance
    if (walletBalance >= chargingCost) {
      setState(() {
        walletBalance -= chargingCost;
      });

      // Update wallet balance in Firebase
      updateWalletBalance();
    } else {
      // Handle insufficient balance scenario
      print('Insufficient balance. Charging stopped.');
    }
  }

  void updateWalletBalance() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'wallet_balance': walletBalance,
      });
    }
  }

  void increaseRemainingCharge() async {

    if (!mounted) {
      // The widget is no longer in the widget tree, avoid state changes
      return;
    }

    SelectedCar selectedCar = Provider.of<SelectedCar>(context, listen: false);

    if (selectedCar != null) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot userSnapshot = await transaction.get(userRef);

          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>?;

            if (userData != null && userData.containsKey('cars')) {
              List<dynamic> userCars = userData['cars'];

              int? selectedCarIndex = selectedCar.selectedCarIndex;

              if (selectedCarIndex != null && selectedCarIndex < userCars.length) {
                int newRemainingCharge = userCars[selectedCarIndex]['remainingCharge'];

                // Increment by 1, apply 1.01 multiplier, and round
                newRemainingCharge = ((newRemainingCharge + 1) * 1.01).round();

                // Fetch the current wallet balance
                double walletBalance = userData['wallet_balance'] ?? 0;

                // Calculate and deduct the charging cost
                double chargingCost = (fee * (_chargingTimer.tick ~/ 5));
                double newWalletBalance = walletBalance - chargingCost;

                // Update user data
                userCars[selectedCarIndex]['remainingCharge'] = newRemainingCharge;
                userData['wallet_balance'] = newWalletBalance;

                // Update Firestore
                await transaction.update(userRef, {'cars': userCars, 'wallet_balance': newWalletBalance});

                // Update the local state to trigger a rebuild
                setState(() {
                  remainingCharge = newRemainingCharge;
                });
              }
            }
          }
        });
      }
    }
  }


  Future<void> updateStationStatus(bool isEmpty) async {
    try {
      await FirebaseFirestore.instance
          .collection('stations')
          .doc(widget.station.id)
          .update({'isEmpty': isEmpty});
    } catch (error) {
      print('Error updating station status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff262930),
      appBar: AppBar(
        title: Text('Charging Details'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            walletBalance >= 0
                ? Text('Wallet Balance: \$${walletBalance.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white))
                : CircularProgressIndicator(),
            Text('Charging Details for ${widget.station.name}', style: TextStyle(color: Colors.white)),
            SizedBox(height: 20),
            Consumer<SelectedCar>(
              builder: (context, selectedCar, child) {
                Map<String, dynamic>? carData = selectedCar.selectedCarIndex != null
                    ? selectedCar.userCars[selectedCar.selectedCarIndex!]
                    : null;

                return carData != null
                    ? Column(
                  children: [
                    Text(
                      'Selected Car: ${carData['name']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Remaining Charge: $remainingCharge%',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: remainingCharge / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorTween(
                                begin: Colors.lightGreen, // Dark color
                                end: Colors.green, // Light color
                              ).lerp(remainingCharge / 100) ?? Colors.lightGreen, // Use light green as default
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color(0xff262930), // Dark color at the center
                                Colors.lightGreen.withOpacity(0), // Light color at the border
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.electric_bolt,
                            size: 100,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ],
                )
                    : Text('No car selected');
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            MaterialButton(
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text('Start Charging', style: TextStyle(fontSize: 16.0)),
                ),
              ),
              onPressed: isChargingStopped ? () {
                // Trigger the functionality to increase remaining charge and set isEmpty to false
                increaseRemainingCharge();
                updateStationStatus(false);
              } : null,
            ),
            SizedBox(height: 20),
            MaterialButton(
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.orange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text('Stop Charging', style: TextStyle(fontSize: 16.0)),
                ),
              ),
              onPressed: isChargingStopped ? null : stopCharging,
            ),
            SizedBox(height: 20),
            MaterialButton(
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orangeAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text('Resume Charging', style: TextStyle(fontSize: 16.0)),
                ),
              ),
              onPressed: isChargingStopped ? resumeCharging : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cancel the timer when the page is disposed
    _chargingTimer.cancel();
    super.dispose();
  }
}
