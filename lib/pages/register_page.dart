import '../auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class RegisterPage extends StatelessWidget {
  final Auth auth;

  RegisterPage({Key? key, required this.auth}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff26B6E1),
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff26B6E1),
              ),
              onPressed: () async {
                try {
                  await auth.createUserWithEmailAndPassword(
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  // Navigate to the home page after successful registration
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(auth: auth),
                    ),
                  );
                } catch (e) {
                  // Handle registration failure (show error message, etc.)
                  print('Registration failed: $e');
                  // Show a snackbar with the error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Registration failed: $e'),
                    ),
                  );
                }
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 16),
            // Rest of your code...
          ],
        ),
      ),
    );
  }
}
