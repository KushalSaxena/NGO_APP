import 'package:flutter/material.dart';
import 'login.dart'; // Import your login page if it's in a different file

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to the Home Page",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Implement your logout logic here
                // For example, you can sign out the user from Firebase
                // and then navigate to the login page.
                // Here's a basic example to navigate to the login page:
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
