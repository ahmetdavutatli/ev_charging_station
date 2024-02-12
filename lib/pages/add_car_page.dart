// add_car_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/car_services.dart';

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
        title: Text('Choose a Car'),
        backgroundColor: const Color(0xff26B6E1),
      ),
      body: _cars.isNotEmpty
          ? ListView.builder(
        itemCount: _cars.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(_cars[index].carName),
              subtitle: Text(_cars[index].manufacturer),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff26B6E1),
                ),
                onPressed: () {
                  _addCarToUserProfile(_cars[index]);
                },
                child: Text('Select Car'),
              ),
            ),
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _addCarToUserProfile(Car selectedCar) async {
    try {
      // Get the current user from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'cars': FieldValue.arrayUnion([
            {
              'name': selectedCar.carName,
              'initialCharge': selectedCar.initialCharge,
              'remainingCharge': selectedCar.initialCharge, // Initially set remainingCharge same as initialCharge
            }
          ]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Car ${selectedCar.carName} added to your profile.'),
          ),
        );
      }
    } catch (e) {
      print('Error adding car to user profile: $e');
    }
  }
}


