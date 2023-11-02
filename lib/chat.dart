import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_ngo_app/chat_page.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Widget _buildUserList(DocumentSnapshot document){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasError){
          return const Text('error');
        }

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Text('Loading');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },);
  }

  Widget _buildUserListItem(DocumentSnapshot document){
    Map<String,dynamic> data = document.data()!as Map<String,dynamic>;

    if(_auth.currentUser!.email != data['email']){
      return ListTile(
        title:  Text(data['email']),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data['email'],
                  receiverUserId: data['uid'],
                )),
          );},
      );
    }else{
      return Container();
    }
  }
}