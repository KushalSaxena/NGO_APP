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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscureText = true;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  String _selectedUserType = 'User'; // Default user type

  Future<void> _togglePasswordVisibility() async {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final username = _userNameController.text;

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password should be at least 6 characters long."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords do not match. Please enter the same password."),
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
      final uid = userCredential.user?.uid;

      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'email': email,
        'uid': uid,
      });

      await _firestore.collection("UsersProfile").doc(userCredential.user!.email!).set({
        'username': username,
        'userType': _selectedUserType, // Added user type
        'bio': 'Empty bio...',
        'profileImage': defaultProfileImageUrl,
      });

      if (userCredential.user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("The email is already in use. Please try another."),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Invalid email format. Please enter a valid email."),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
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
                      SizedBox(height: 1.0),
                      Image.asset(
                        "assets/xyz_abc.png",
                        width: 350,
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
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      obscureText: _obscureText,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        icon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      obscureText: _obscureText,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUserType = newValue!;
                        });
                      },
                      items: <String>['User', 'NGO']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: "User Type",
                        icon: Icon(Icons.person),
                      ),
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

const String defaultProfileImageUrl =
    'https://thepluginpeople.atlassian.net/wiki/aa-avatar/557058:3fbe1a47-28ff-4ca5-a1fc-60f24c53b89d';
