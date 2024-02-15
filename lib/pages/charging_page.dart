import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../auth.dart';
import '../models/station_model.dart';
import '../navbar.dart';
import '../selected_car.dart';
import 'charging_details_page.dart';

class ChargingPage extends StatefulWidget {
  @override
  _ChargingPageState createState() => _ChargingPageState();
}

class _ChargingPageState extends State<ChargingPage> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool chargingDetailsPageOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        cameraFacing: CameraFacing.back,
        overlay: QrScannerOverlayShape(),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((Barcode scanData) {
      _handleScannedData(scanData.code);
    });
  }

  void _handleScannedData(String? data) async {
    if (data != null) {
      int stationId = int.tryParse(data) ?? 0;
      Station? selectedStation = await getStationByStationId(stationId);

      print('Scanned QR Code: $data');

      if (selectedStation != null) {
        // Check if ChargingDetailsPage is already in the stack
        bool isChargingDetailsPageOpen = Navigator.of(context).canPop();

        if (!isChargingDetailsPageOpen) {
          // Only push a new ChargingDetailsPage if it's not already in the stack
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChargingDetailsPage(station: selectedStation),
            ),
          );
        }
      } else {
        print('Selected station is not available or not empty.');
      }
    }
  }


  Future<Station?> getStationByStationId(int? stationID) async {
    try {
      QuerySnapshot stationSnapshot = await FirebaseFirestore.instance
          .collection('stations')
          .where('stationID', isEqualTo: stationID)
          .get();

      if (stationSnapshot.docs.isNotEmpty) {
        return Station.fromFirestore(
          stationSnapshot.docs.first.data() as Map<String, dynamic>,
          stationSnapshot.docs.first.id,
        );
      } else {
        print('Station not found for ID: $stationID');
        return null;
      }
    } catch (error) {
      print('Error retrieving station: $error');
      return null;
    }
  }

  Future<void> updateStationStatus(Station station, bool isEmpty) async {
    try {
      await FirebaseFirestore.instance
          .collection('stations')
          .doc(station.id)
          .update({'isEmpty': isEmpty});
    } catch (error) {
      print('Error updating station status: $error');
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ChargingDetailsPageRoute extends PageRouteBuilder {
  final Station station;

  ChargingDetailsPageRoute({required this.station})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) =>
        ChargingDetailsPage(station: station),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
