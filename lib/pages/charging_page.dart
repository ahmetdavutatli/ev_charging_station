import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../auth.dart';
import '../models/station_model.dart';
import '../navbar.dart';
import '../selected_car.dart';
import 'charging_details_page.dart';
import '../global_stations.dart' as global_stations;

class ChargingPage extends StatefulWidget {
List<Station> stations= global_stations.stations;

  ChargingPage({required this.stations});

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
      int scannedIndex = int.tryParse(data) ?? 0;

      Station? selectedStation = widget.stations.firstWhere(
            (station) => station.id == scannedIndex.toString(),
        orElse: () => Station(id: '-1', name: 'Default Station', latitude: 1.0, longitude: 1.0, address: 'Default Address'),
      );

      print('Scanned QR Code: $data');

      if (selectedStation != null) {
        bool isChargingDetailsPageOpen = Navigator.of(context).canPop();

        if (!isChargingDetailsPageOpen) {
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


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
