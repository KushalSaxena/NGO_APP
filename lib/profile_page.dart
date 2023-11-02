import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:major_ngo_app/profile_picture_view.dart';
import 'package:major_ngo_app/text_box.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'ApplicationStatusPage.dart';
import 'ManageApplicationsPage.dart';
import 'home.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('Users');
  File? _profileImage;
  bool _obscureText = true;

  Future<void> _togglePasswordVisibility() async {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_profileImage != null) {
      final fileName = currentUser.email! + '_profile_image';
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images/$fileName.jpg');
      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } else {
      return '';
    }
  }

  Future<void> editField(String field) async {
    if (field == 'profileImage') {
      await _pickImage();
      String downloadUrl = await _uploadImage();
      if (downloadUrl.isNotEmpty) {
        await userCollection
            .doc(currentUser.email)
            .update({'profileImage': downloadUrl});
      }
    } else {
      String newValue = "";
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Edit $field",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              newValue = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: Text(
                'save',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
      if (newValue.trim().length > 0) {
        await userCollection.doc(currentUser.email).update({field: newValue});
      }
    }
  }

  void _viewProfilePicture(BuildContext context, String? imageUrl) {
    if (imageUrl != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfilePictureViewPage(imageUrl: imageUrl),
      ));
    }
  }

  Future<void> _showImageOptionsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Profile Picture Options"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _viewImage();
              },
              child: Text("View Image"),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _pickImage();
              },
              child: Text("Update Image"),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _removeImage();
              },
              child: Text("Remove Image"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewImage() async {
    if (userData['profileImage'] != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ProfilePictureViewPage(imageUrl: userData['profileImage']),
      ));
    }
    // Implement code to view the image
    // Navigate to a different page to view the image
  }

  Future<void> _removeImage() async {
    setState(() {
      _profileImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.grey[900],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            ListTile(
              title: Text('Application Status'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ApplicationStatusPage()),
                );
              },
            ),
            ListTile(
              title: Text('Manage Applications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageApplicationsPage(
                      opportunityId: '1234',
                      opportunityName: 'Volunteer Opportunity',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    _showImageOptionsDialog();
                  },
                  child: Hero(
                    tag: 'profileImage',
                    child: CircleAvatar(
                      radius: 120,
                      backgroundImage: userData['profileImage'] != null
                          ? NetworkImage(userData['profileImage'])
                          : null,
                      child: _profileImage != null
                          ? null
                          : userData['profileImage'] == null
                          ? Icon(Icons.person, size: 72)
                          : null,
                    ),
                  ),
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

