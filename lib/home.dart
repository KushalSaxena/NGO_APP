import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:major_ngo_app/PostOpportunityPage.dart';
import 'package:major_ngo_app/Volunteer_Opportunities.dart';
import 'package:major_ngo_app/chat.dart';
import 'package:major_ngo_app/helper/helper_methods.dart';
import 'package:major_ngo_app/post.dart';
import 'package:major_ngo_app/search.dart';
import 'package:major_ngo_app/profile_page.dart';
import 'about.dart';
import 'chat_page.dart';
import 'login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  File? _selectedImage;

  void postMessage() async {
    if (textController.text.isNotEmpty || _selectedImage != null) {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'ImageURL': imageUrl,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });

      textController.clear();
      setState(() {
        _selectedImage = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final fileName =
        "${currentUser.email}_${DateTime.now().millisecondsSinceEpoch}_post_image";
    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('post_images/$fileName.jpg');
    await ref.putFile(image);
    final downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Perform logout and navigate to the login page
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat with User'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Chat(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text(' VolunteerOpportunities'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VolunteerOpportunities(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Search'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Search(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('PostOpportunityPage'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostOpportunityPage(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AboutPage(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: true)
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
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        time: formatDate(post["TimeStamp"]),
                        imageUrl: post['ImageURL'],
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
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                ),
              ],
            ),
          ),
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
