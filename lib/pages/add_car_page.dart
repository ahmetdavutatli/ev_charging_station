import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/car_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCarPage extends StatefulWidget {
  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final CarService _carService = CarService();
  late List<Car> _cars = [];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      List<Car> cars = await _carService.getCars();
      setState(() {
        _cars = cars;
      });
    } catch (e) {
      print('Error loading cars: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 60, width: 60),
        backgroundColor: Colors.green,
      ),
      body: _cars.isNotEmpty
          ? ListView.builder(
        itemCount: _cars.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xff262930),
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(_cars[index].carName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(_cars[index].manufacturer, style: const TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  _addCarToUserProfile(_cars[index]);
                },
                child: Text(AppLocalizations.of(context)!.selectCar, style: const TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
      backgroundColor: const Color(0xff262930),
    );
  }

  void _addCarToUserProfile(Car selectedCar) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'cars': FieldValue.arrayUnion([
            {
              'name': selectedCar.carName,
              'initialCharge': selectedCar.initialCharge,
              'remainingCharge': selectedCar.initialCharge,
            }
          ]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Car ${selectedCar.carName} added to your profile.'),
          ),
        );
        Navigator.of(context).pop(); // Close the Add Car page after adding a car
      }
    } catch (e) {
      print('Error adding car to user profile: $e');
    }
  }
}
