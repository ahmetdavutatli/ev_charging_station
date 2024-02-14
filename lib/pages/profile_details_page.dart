import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ProfileDetailsPage extends StatefulWidget {
  final Auth auth;

  const ProfileDetailsPage({Key? key, required this.auth}) : super(key: key);

  @override
  _ProfileDetailsPageState createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get the current user's document from Firestore
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.auth.user?.uid)
          .get();

      // Extract user data
      String name = userDocument['name'] ?? '';
      String email = userDocument['email'] ?? '';

      // Set the controller values
      _nameController.text = name;
      _emailController.text = email;

    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateUserData() async {
    try {
      // Validate and update user data in Firestore
      if (_passwordController.text.isNotEmpty) {
        await widget.auth.signInWithEmailAndPassword(
          email: widget.auth.user?.email ?? '',
          password: _passwordController.text,
        );

        // Update user data
        await FirebaseFirestore.instance.collection('users').doc(widget.auth.user?.uid).update({
          'name': _nameController.text,
          'email': _emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)));
      } else {
        _showPasswordErrorAlert(AppLocalizations.of(context)!.passwordRequired);
      }
    } catch (e) {
      print('Error updating user data: $e');

      // Check if the error is a FirebaseAuthException
      if (e is FirebaseAuthException) {

        // Check for specific error codes
        if (e.code == 'invalid-credential') {
          // Display an error message for an incorrect credential
          _showPasswordErrorAlert(AppLocalizations.of(context)!.invalidPassword);
        } else {
          _showPasswordErrorAlert('Error updating user data. Please try again.');
        }
      } else {
        _showPasswordErrorAlert('Error updating user data. Please try again.');
      }
    }
  }

  void _showPasswordErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.error),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff26B6E1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name TextField
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
            ),

            SizedBox(height: 16),

            // Email TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
            ),

            SizedBox(height: 16),

            // Password TextField
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
              obscureText: true,
            ),

            SizedBox(height: 20),

            // Update Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff26B6E1),
              ),
              onPressed: _updateUserData,
              child: Text(AppLocalizations.of(context)!.update),
            ),
          ],
        ),
      ),
    );
  }
}
