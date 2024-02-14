import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ev_charging_station/models/station_model.dart';
import 'package:ev_charging_station/services/station_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../auth.dart';
import '../navbar.dart';
import 'home_page.dart';

class ChargingDetailsPage extends StatefulWidget {
  final Station station;

  ChargingDetailsPage({required this.station});

  @override
  _ChargingDetailsPageState createState() => _ChargingDetailsPageState();
}

class _ChargingDetailsPageState extends State<ChargingDetailsPage> {
  late List<Map<String, dynamic>> _userCars;
  Timer? _chargingTimer;
  bool _chargingStarted = false;
  late int _selectedCarIndex;

  @override
  void initState() {
    super.initState();
    _userCars = [];
    _selectedCarIndex = -1;
    _loadUserCars();
  }

  Future<void> _loadUserCars() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('cars')) {
          List<dynamic> userCars = userData['cars'];

          setState(() {
            _userCars = userCars.map((car) {
              return {
                'name': car['name'],
                'initialCharge': car['initialCharge'],
                'remainingCharge': (car['remainingCharge'] is double)
                    ? (car['remainingCharge'] as double).toInt()
                    : car['remainingCharge'], // Convert to int if it's a double
              };
            }).toList().cast<Map<String, dynamic>>();
          });
        }
      }
    }
  }

  Future<void> _updateRemainingChargeInFirestore(int remainingCharge) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('cars')) {
          List<dynamic> userCars = userData['cars'];

          if (_selectedCarIndex >= 0 && _selectedCarIndex < userCars.length) {
            userCars[_selectedCarIndex]['remainingCharge'] = remainingCharge.toDouble(); // Convert to double
          }

          await userRef.update({'cars': userCars});

          // Reload user cars after updating Firestore
          await _loadUserCars();

          // Update the local _userCars variable
          setState(() {
            _userCars = userCars.cast<Map<String, dynamic>>();
          });
        }
      }
    }
  }



  void _startCharging(int index) {
    if (!_chargingStarted) {
      _selectedCarIndex = index;
      _chargingStarted = true;

      _chargingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (mounted) {
          setState(() {
            if (_userCars[_selectedCarIndex]['remainingCharge'] < 100) {
              // Ensure the value is an int before incrementing
              int remainingCharge = _userCars[_selectedCarIndex]['remainingCharge'].toInt();
              remainingCharge += 1;

              _userCars[_selectedCarIndex]['remainingCharge'] = remainingCharge;
              _updateRemainingChargeInFirestore(remainingCharge);
            } else {
              timer.cancel();
              _stopCharging();
            }
          });
        }
      });
    } else {
      _stopCharging();
    }
  }

  void _stopCharging() {
    _chargingTimer?.cancel();
    _chargingStarted = false;
    _selectedCarIndex = -1;
  }

  @override
  void dispose() {
    _chargingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff26B6E1),
        title: Text(AppLocalizations.of(context)!.stationInfo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${AppLocalizations.of(context)!.stationName}: ${widget.station.name}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '${AppLocalizations.of(context)!.stationLocation}: ${widget.station.latitude}, ${widget.station.longitude}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              '${AppLocalizations.of(context)!.stationAddress}: ${widget.station.address}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16),
            _userCars.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: _userCars.length,
                itemBuilder: (context, index) {
                  return Card(
                      elevation: 3.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(
                          _userCars[index]['name'],
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${AppLocalizations.of(context)!.initialCharge}: ${_userCars[index]['initialCharge'].toString()}%' +
                              '\n${AppLocalizations.of(context)!.remainingCharge}: ${_userCars[index]['remainingCharge'].toString()}%',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff26B6E1),
                          ),
                          onPressed: () {
                            _startCharging(index);
                          },
                          child: Text(_chargingStarted ? AppLocalizations.of(context)!.stopCharging : AppLocalizations.of(context)!.startCharging
                          ),
                        ),
                      ));
                },
              ),
            )
                : Text(AppLocalizations.of(context)!.carCheck),
          ],
        ),
      ),
    );
  }
}