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

class MyCarsPage extends StatefulWidget {
  const MyCarsPage({Key? key}) : super(key: key);

  @override
  State<MyCarsPage> createState() => _MyCarsPageState();
}

class _MyCarsPageState extends State<MyCarsPage> {
  late List<Map<String, dynamic>> _userCars = [];
  late Timer _timer;

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
    // Set up a timer to decrease remaining charge every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _decreaseRemainingCharge();
      }
    });
  }

  void _decreaseRemainingCharge() async {
    if (mounted) {
      ChargeState chargeState = _getChargeState(context);

      // Update Firestore and get the updated data
      await _updateRemainingChargeInFirestore();

      // Fetch the updated user cars after updating Firestore
      await _loadUserCars();

      // Update the provider with the new list of cars
      chargeState.updateUserCharge(_userCars);
    }
  }

  Future<void> _updateRemainingChargeInFirestore() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user document
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('cars')) {
          List<dynamic> userCars = userData['cars'];

          // Update the remainingCharge field for each car
          for (int i = 0; i < userCars.length; i++) {
            if (userCars[i]['remainingCharge'] > 0) {
              userCars[i]['remainingCharge'] -= 1;
            }
          }

          // Update the user document in Firestore
          await userRef.update({'cars': userCars});

          // Update the local _userCars variable
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
      // User logged out, cancel the timer
      _timer.cancel();
    }
  }

  Future<void> _loadUserCars() async {
    // Only load user cars if they haven't been loaded before
    if (_userCars.isEmpty) {
      // Get the current authenticated user's UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Reference to the user document in Firestore
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

        // Get the user document
        DocumentSnapshot userSnapshot = await userRef.get();

        if (userSnapshot.exists) {
          // Check if the 'cars' field exists in the user document
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
    Auth auth = Provider.of<Auth>(context);
    return Scaffold(
      drawer: NavBar(auth: Auth()),
      appBar: AppBar(
        backgroundColor: const Color(0xff26B6E1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChangeNotifierProvider(
          create: (_) => ChargeState(), // Add this line
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCarPage()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.addCar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
