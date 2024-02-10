import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ev_charging_station/models/station_model.dart';
import 'package:ev_charging_station/services/station_services.dart';

import 'home_page.dart';

class ChargingPage extends StatefulWidget {
  final StationService stationService;

  ChargingPage({required this.stationService});

  @override
  _ChargingPageState createState() => _ChargingPageState();
}

class _ChargingPageState extends State<ChargingPage> {
  late List<Station> _stations;

  @override
  void initState() {
    super.initState();
    _stations = [];
    _loadStations();
  }

  Future<void> _loadStations() async {
    List<Station> stations = await widget.stationService.getStations();
    setState(() {
      _stations = stations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charging Stations'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: _stations.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                _stations[index].name,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Location: ${_stations[index].latitude}, ${_stations[index].longitude}',
                style: TextStyle(fontSize: 14.0),
              ),
              onTap: () {
                _navigateToMap(_stations[index]);
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToMap(Station station) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePageContent(focusedStation: station),
      ),
    );
  }
}

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
            _userCars = userCars.cast<Map<String, dynamic>>();
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
            userCars[_selectedCarIndex]['remainingCharge'] = remainingCharge;
          }

          await userRef.update({'cars': userCars});

          await _loadUserCars();
        }
      }
    }
  }

  void _startCharging(int index) {
    if (!_chargingStarted) {
      _selectedCarIndex = index;
      _chargingStarted = true;

      // Start the charging timer
      _chargingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (mounted) {
          setState(() {
            if (_userCars[_selectedCarIndex]['remainingCharge'] < 100) {
              _userCars[_selectedCarIndex]['remainingCharge'] += 1;
              _updateRemainingChargeInFirestore(_userCars[_selectedCarIndex]['remainingCharge']);
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
    // Ensure that _chargingTimer is canceled before disposing
    _chargingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff26B6E1),
        title: Text('Charging Station Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Station Name: ${widget.station.name}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Location: ${widget.station.latitude}, ${widget.station.longitude}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Address: ${widget.station.address}',
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
                        'Initial Charge: ${_userCars[index]['initialCharge'].toString()}%' +
                            '\nRemaining Charge: ${_userCars[index]['remainingCharge'].toString()}%',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff26B6E1),
                        ),
                        onPressed: () {
                          _startCharging(index);
                        },
                        child: Text(_chargingStarted ? 'Stop Charging' : 'Start Charging'),
                      ),
                    ),
                  );
                },
              ),
            )
                : Text('No cars added yet.'),
          ],
        ),
      ),
    );
  }
}
