import 'package:flutter/material.dart';
import '../auth.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final Auth auth;

  LoginPage({Key? key, required this.auth}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add your logo here
            Image.asset(
              'assets/logo.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.green.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.green.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
            ),
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
                  constraints: const BoxConstraints(maxWidth: 200, minHeight: 50),
                  alignment: Alignment.center,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              onPressed: () async {
                  if(emailController.text.isEmpty || passwordController.text.isEmpty){
                    showDialog(context: context,
                        builder: (BuildContext context){
                      return Theme(
                        data: ThemeData( dialogBackgroundColor: Colors.black,),
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Text('Error', style: TextStyle(color: Colors.green),),
                          content: Text('Please enter email and password', style: TextStyle(color: Colors.green),),
                          actions: <Widget> [
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: Text('OK', style: TextStyle(color: Colors.green),),
                            ),
                          ],
                        ),
                        );
                    },
                    );
                  }else{
                    try {
                      await auth.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      // Navigate to the home page after login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(auth: auth),
                        ),
                      );
                    } catch (e) {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Invalid email or password'),
                          actions: [
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                      );
                    }
                  }
              },

            ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              onPressed: () {
                // Navigate to the registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage(auth: auth)),
                );
              },
              child: Text(
                "Don't have an account? Register here.",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
