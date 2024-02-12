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
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.green,
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            _buildTextField(nameController, 'Name'),
            const SizedBox(height: 16),
            _buildTextField(emailController, 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(passwordController, 'Password', obscureText: true),
            const SizedBox(height: 16),
            MaterialButton(
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 200.0,
                    minHeight: 50.0,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Register",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              onPressed: () async {
                try {
                  await auth.createUserWithEmailAndPassword(
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(auth: auth),
                    ),
                  );
                } catch (e) {
                  print('Registration failed: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Registration failed: $e'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Already have an account? Login here.',
                  style: TextStyle(color: Colors.green),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
      }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.green.withOpacity(0.2),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}
