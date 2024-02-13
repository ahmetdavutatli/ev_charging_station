import 'package:ev_charging_station/pages/login_page.dart';
import 'package:ev_charging_station/pages/profile_details_page.dart';
import 'package:ev_charging_station/pages/transaction_page.dart';
import 'package:ev_charging_station/pages/wallet_page.dart';
import 'package:ev_charging_station/services/wallet_services.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavBar extends StatelessWidget {
  final Auth auth;

  NavBar({Key? key, required this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xff262930),
      child: FutureBuilder(
        future: fetchData(), // Function to fetch data from Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while fetching data
          } else {
            String accountName = snapshot.data?['name'];

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(accountName),
                        accountEmail: null,
                        currentAccountPicture: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileDetailsPage(auth: auth)),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.account_circle),
                            title: Text(
                              'Profile Details',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalletPage(
                                    auth: auth,
                                    walletService: WalletService(auth: auth))),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.wallet),
                            title: Text(
                              'Wallet',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          // Navigate to Transactions Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TransactionPage()),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.access_time_filled),
                            title: Text(
                              'Transactions',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 20, color: Colors.lightGreen),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          // Navigate to About Us Page
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.info),
                            title: Text(
                              'About Us',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        // Wrap the ListTile in a Container to apply custom styling
                        tileColor: Colors.transparent,
                        // Set tileColor to transparent so the gradient background is visible
                        onTap: () {
                          // Navigate to Privacy and Complience Page
                        },
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        // Adjust padding as needed
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            // Set the border radius as needed
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.lightGreen],
                              // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.lock),
                            title: Text(
                              'Privacy & Compliance',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set text color to contrast with the gradient background
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  // Wrap the ListTile in a Container to apply custom styling
                  tileColor: Colors.transparent,
                  // Set tileColor to transparent so the gradient background is visible
                  onTap: () async {
                    await auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(auth: Auth())),
                    );
                  },
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  // Adjust padding as needed
                  title: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      // Set the border radius as needed
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                        // Set your gradient colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors
                                .white), // Set text color to contrast with the gradient background
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchData() async {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Use Firestore to get user data based on the current user's UID
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      return documentSnapshot.data()!;
    } else {
      // Handle the case when there is no current user
      return {};
    }
  }
}
