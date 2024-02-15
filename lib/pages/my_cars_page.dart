import 'dart:async';
import 'package:provider/provider.dart';
import '../auth.dart';
import '../charge_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../navbar.dart';
import 'add_car_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../selected_car.dart';

class MyCarsPage extends StatefulWidget {
  const MyCarsPage({Key? key}) : super(key: key);

  @override
  State<MyCarsPage> createState() => _MyCarsPageState();
}

class _MyCarsPageState extends State<MyCarsPage> {
  late List<Map<String, dynamic>> _userCars = [];
  late Timer _timer;
  String? _selectedCarId;

  ChargeState _getChargeState(BuildContext context) {
    return context.read<ChargeState>();
  }

  @override
  void initState() {
    super.initState();
    _loadUserCars();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _decreaseRemainingCharge();
      }
    });
  }

  void _decreaseRemainingCharge() async {
    if (mounted) {
      ChargeState chargeState = _getChargeState(context);

      await _updateRemainingChargeInFirestore();

      await _loadUserCars();

      chargeState.updateUserCharge(_userCars);
    }
  }

  Future<void> _updateRemainingChargeInFirestore() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('cars')) {
          List<dynamic> userCars = userData['cars'];

          for (int i = 0; i < userCars.length; i++) {
            if (userCars[i]['remainingCharge'] > 0) {
              userCars[i]['remainingCharge'] -= 1;
            }
          }

          await userRef.update({'cars': userCars});

          setState(() {
            _userCars = userCars.cast<Map<String, dynamic>>();
          });
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<Auth>(context, listen: false).user == null) {
      _timer.cancel();
    }
  }

  Future<void> _loadUserCars() async {
    if (_userCars.isEmpty) {
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
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SelectedCar selectedCar = Provider.of<SelectedCar>(context);
    Auth auth = Provider.of<Auth>(context);

    if (selectedCar == null) {
      // Print an error message and return a placeholder widget
      print("SelectedCar is null in build method");
      return Container(); // You can replace this with an appropriate widget
    }

    return Scaffold(
      drawer: NavBar(auth: Auth()),
      appBar: AppBar(
        backgroundColor: const Color(0xff26B6E1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChangeNotifierProvider<ChargeState>(
          create: (_) => ChargeState(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _userCars.isNotEmpty
                  ? Expanded(
                child: ListView.builder(
                  itemCount: _userCars.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(_userCars[index]['name']),
                        subtitle: Text(
                          '${AppLocalizations.of(context)!.initialCharge}: ${_userCars[index]['initialCharge'].toString()}%' +
                              '\n${AppLocalizations.of(context)!.remainingCharge}: ${_userCars[index]['remainingCharge'].toString()}%',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Call the method to select the car by index
                            _toggleChooseCar(index);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedCar.selectedCarIndex == index
                                ? Colors.green
                                : const Color(0xff26B6E1),
                          ),
                          child: Text(
                            selectedCar.selectedCarIndex == index
                                ? 'Selected Car'
                                : 'Choose Car',
                            style: TextStyle(
                              color: selectedCar.selectedCarIndex == index
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                        ),
                        tileColor: selectedCar.selectedCarIndex == index
                            ? Colors.green
                            : null, // Highlight the selected car
                      ),
                    );
                  },
                ),
              )
                  : Text(AppLocalizations.of(context)!.carCheck),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff26B6E1),
                ),
                onPressed: () {
                  _showAddCarDialog();
                },
                child: Text(AppLocalizations.of(context)!.addCar),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleChooseCar(int index) {
    SelectedCar selectedCar = Provider.of<SelectedCar>(context, listen: false);

    if (selectedCar == null) {
      print("SelectedCar is null");
      return;
    }

    if (selectedCar.selectedCarIndex == index) {
      // If the selected car is tapped again, unselect it
      selectedCar.selectCar(null);
    } else {
      // Otherwise, select the tapped car
      selectedCar.selectCar(index);

      // Update SelectedCar with the latest userCars information
      selectedCar.updateUserCars(_userCars);
    }

    // Print the selected car for debugging
    print("Selected Car Index: ${selectedCar.selectedCarIndex}");

    // Call setState to trigger a rebuild of the UI
    if (mounted) {
      setState(() {});
    }
  }







  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a New Car'),
          content: Text('Do you want to add a new car?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToAddCarPage();
              },
              child: Text('Add Car'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddCarPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCarPage()),
    );
  }
}
