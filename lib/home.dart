import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:major_ngo_app/post.dart'; // Replace with the correct import path for your Post widget
import 'login.dart'; // Import your login page if it's in a different file

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
      });

      // Clear the text field and update the UI
      textController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Home Page"),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return Post(
                        message: post['Message'],
                        user: post['UserEmail'],
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          // Post message
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: TextStyle(color: Colors.black),
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Write something on the page',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: postMessage,
                  icon: Icon(Icons.arrow_circle_up),
                ),
              ],
            ),
          ),
          // Logged in as
          Text(
            "Logged in as: " + currentUser.email!,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
