import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:major_ngo_app/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final userCollection = FirebaseFirestore.instance.collection('Users');

  Future<void> editField(String field) async {
    String newValue="";
    await showDialog(context: context, builder: (context)=>AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text("Edit $field",
      style: TextStyle(color:Colors.white),
    ),
      content: TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter new $field",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value){
          newValue=value;
        },
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context),
            child: Text('cancel',
              style: TextStyle(color: Colors.white),
            )
        ),
        TextButton(onPressed: ()=> Navigator.of(context).pop(newValue),
            child: Text('save',
              style: TextStyle(color: Colors.white),
            )
        )
      ],
    )
    );
    if (newValue.trim().length>0){

      await userCollection.doc(currentUser.email).update({field: newValue});

    }
    // Implement your logic for editing the field here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                SizedBox(height: 50),
                Icon(
                  Icons.person,
                  size: 72,
                ),
                SizedBox(height: 10),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Posts',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error ${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
