import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_charging_station/services/wallet_services.dart';
import 'package:flutter/material.dart';
import '../auth.dart';
import 'login_page.dart';
import 'transaction_page.dart';
import 'profile_details_page.dart';
import 'wallet_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.auth}) : super(key: key);

  final Auth auth;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      // Get the current user's document from Firestore
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.auth.user?.uid)
          .get();

      // Get the name from the document
      _userName = userDocument['name'] ?? 'Unknown';
      setState(() {});
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xff26B6E1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hello, $_userName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Profile Details Section
            _buildSectionButton(
              title: 'Profile Details',
              color: const Color(0xff262930),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDetailsPage(auth: widget.auth)),
                );
              },
            ),

            const Divider(height: 20, color: const Color(0xff26B6E1)),

            // Wallet Section
            _buildSectionButton(
              title: 'Wallet',
              color: const Color(0xff262930),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WalletPage(auth: widget.auth, walletService: WalletService(auth: widget.auth) )),
                );
              },
            ),

            const Divider(height: 20, color: const Color(0xff26B6E1)),

            // Transactions Section
            _buildSectionButton(
              title: 'Transactions',
              color: const Color(0xff262930),
              onTap: () {
                // Navigate to Transactions Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransactionPage()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildLogoutButton(),
      ),
    );
  }

  Widget _buildSectionButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        primary: color,
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, color: const Color(0xff26B6E1)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () async {
        await widget.auth.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(auth: Auth())),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: const Color(0xff262930), // Change the color to red
      ),
      child: const Text(
        'Logout',
        style: TextStyle(fontSize: 18, color: const Color(0xff26B6E1)),
      ),
    );
  }
}
