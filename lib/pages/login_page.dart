import 'package:ev_charging_station/pages/home_page.dart';
import 'package:flutter/material.dart';
import '../auth.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {

  final Auth auth;

  LoginPage({super.key, required this.auth});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email',
              filled: true,
              fillColor: Color(0xff26B6E1),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff26B6E1)),
                borderRadius: BorderRadius.circular(10),
              )),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Color(0xff26B6E1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff26B6E1)),
                    borderRadius: BorderRadius.circular(10),
                  )
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff26B6E1),
              ),
              onPressed: () async {
                if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                  // Show an alert for empty email or password
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please enter both email and password.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  try {
                    await auth.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    // Navigate to the home page after successful login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(auth: auth,)),
                    );
                  } catch (e) {
                    // Show an alert for invalid login
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Invalid email or password. Please try again.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    print('Login failed: $e');
                  }
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff26B6E1),
              ),
              onPressed: () {
                // Navigate to the registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(auth: auth)),
                );
              },
              child: const Text('Don\'t have an account? Register here.'),
            ),
          ],
        ),
      ),
    );
  }
}
