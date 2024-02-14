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
      drawer: NavBar(auth: Auth(),),
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
                '${AppLocalizations.of(context)!.stationLocation}: ${_stations[index].latitude}, ${_stations[index].longitude}',
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


