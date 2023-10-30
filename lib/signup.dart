import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  Future<void> _togglePasswordVisibility() async {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Function to handle signup
  Future<void> _handleSignup() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (password.length < 6) {
      // Display an error message for a password that's too short
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password should be at least 6 characters long."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseFirestore.instance.collection("Users")
          .doc(userCredential.user!.email!)
          .set({
        'username': email.split('@')[0],
        'bio':'Empty bio...'
      });
      if (userCredential.user != null) {
        // Signup successful, navigate to the login page
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // Handle the case where the email is already in use
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("The email is already in use. Please try another."),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Handle other signup errors
        print("Signup Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid credentials. Please try again."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up Page"),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg2.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10.0),
                  Column(
                    children: [
                      Text(
                        "Cause",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Connect",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 1.0),
                      Image.asset(
                        "assets/logo.png",
                        width: 200,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        hintText: "Username",
                        icon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        icon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: "Password",
                        icon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      obscureText: _obscureText,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handleSignup,
                    child: Text("Sign Up"),
                  ),
                  SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ));
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}