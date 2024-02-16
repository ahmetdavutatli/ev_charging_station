import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 60, width: 60),
      ),
      body: TransactionList(),
      backgroundColor: Color(0xff262930),
    );
  }
}

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No transactions yet.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var transaction = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Check for the existence of required fields
              if (transaction.containsKey('selected_car_name') &&
                  transaction.containsKey('charging_cost') &&
                  transaction.containsKey('station_address') &&
                  transaction.containsKey('station_name') &&
                  transaction.containsKey('seconds_charged') &&
                  transaction.containsKey('timestamp')) {
                return TransactionCard(
                  selectedCarName: transaction['selected_car_name'],
                  chargingCost: transaction['charging_cost'],
                  stationName: transaction['station_name'],
                  stationAddress: transaction['station_address'],
                  secondsCharged: transaction['seconds_charged'],
                  timestamp: transaction['timestamp'].toDate(),
                );
              } else {
                // Log or handle the case where required fields are missing
                print('Transaction document is missing required fields.');
                return Container(); // You can return an empty container or handle it differently.
              }
            },
          );
        },
      );
    } else {
      return Center(child: Text('User not logged in.'));
    }
  }
}

class TransactionCard extends StatelessWidget {
  final String selectedCarName;
  final double chargingCost;
  final String stationAddress;
  final String stationName;
  final int secondsCharged;
  final DateTime timestamp;

  TransactionCard({
    required this.selectedCarName,
    required this.chargingCost,
    required this.stationAddress,
    required this.stationName,
    required this.secondsCharged,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xff262930),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          selectedCarName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Charging Cost: \$${chargingCost.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Station Name: $stationName',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Station Address: $stationAddress',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Charging Duration: $secondsCharged minutes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Timestamp: ${timestamp.toString()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
