import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Users')),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var users = snapshot.data!.docs
            .where((doc) =>
        _auth.currentUser!.email != (doc.data() as Map)['email'])
            .toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(users[index]);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return ListTile(
      leading: CircleAvatar(
        // You can use an image here if you have one, or use the first letter of the user's name as an avatar.
        child: Text(data['email'][0].toUpperCase()),
      ),
      title: Text(data['email']),
      subtitle: Text("Online"), // Add online status or other information if available.
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverUserEmail: data['email'],
              receiverUserId: data['uid'],
            ),
          ),
        );
      },
    );
  }
}
