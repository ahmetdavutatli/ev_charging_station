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

  @override
  void initState() {
    super.initState();
    startCharging();
  }

  @override
  void dispose() {
    _chargingTimer.cancel();
    super.dispose();
  }

  void startCharging() {
    const chargingInterval = Duration(seconds: 5);
    _chargingTimer = Timer.periodic(chargingInterval, (timer) {
      increaseRemainingCharge();
    });
  }

  Future<void> increaseRemainingCharge() async {
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
                int remainingCharge = userCars[selectedCarIndex]['remainingCharge'];
                remainingCharge = ((remainingCharge + 1) * 1.01).round();

                userCars[selectedCarIndex]['remainingCharge'] = remainingCharge;

                await transaction.update(userRef, {'cars': userCars});
              }
            }
          }
        });

        // Trigger a rebuild of the widget after updating the data
        setState(() {});
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
      appBar: AppBar(
        title: Text('Charging Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Charging Details for ${widget.station.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Remaining Charge: ${carData['remainingCharge']}%',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                )
                    : Text(
                  'No car selected',
                  style: TextStyle(fontSize: 18),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                increaseRemainingCharge();
                updateStationStatus(false);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Start Charging'),
            ),
          ],
        ),
      ),
    );
  }
}
