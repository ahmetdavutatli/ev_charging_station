import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';

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
      // Handle error
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateUserData() async {
    try {
      // Validate and update user data in Firestore
      if (_passwordController.text.isNotEmpty) {
        // Check the password before updating
        // You may want to implement additional security measures here
        // For simplicity, this example only checks if the password is not empty
        await widget.auth.signInWithEmailAndPassword(
          email: widget.auth.user?.email ?? '',
          password: _passwordController.text,
        );

        // Update user data
        await FirebaseFirestore.instance.collection('users').doc(widget.auth.user?.uid).update({
          'name': _nameController.text,
          'email': _emailController.text,
        });

        // Display a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User data updated successfully!')));
      } else {
        // Display an error message if the password is empty
        _showPasswordErrorAlert('Please enter your password to update user data.');
      }
    } catch (e) {
      // Handle authentication errors
      print('Error updating user data: $e');

      // Check if the error is a FirebaseAuthException
      if (e is FirebaseAuthException) {

        // Check for specific error codes
        if (e.code == 'invalid-credential') {
          // Display an error message for an incorrect credential
          _showPasswordErrorAlert('Invalid password. Please try again.');
        } else {
          // Handle other authentication errors
          // ...

          // Display a generic error message
          _showPasswordErrorAlert('Error updating user data. Please try again.');
        }
      } else {
        // Handle other errors (not related to FirebaseAuthException)
        // Display a generic error message
        _showPasswordErrorAlert('Error updating user data. Please try again.');
      }
    }
  }

  void _showPasswordErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Password'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
        title: Text('Profile Details'),
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
              decoration: InputDecoration(labelText: 'Name'),
            ),

            SizedBox(height: 16),

            // Email TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),

            SizedBox(height: 16),

            // Password TextField
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            SizedBox(height: 20),

            // Update Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff26B6E1),
              ),
              onPressed: _updateUserData,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
