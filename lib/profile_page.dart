import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('UsersProfile');
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
  Future<void> removeImage() async {
    setState(() {
      _profileImage = null;
    });

    await userCollection.doc(currentUser.email).update({'profileImage': ''});
  }

  Future<String> _uploadImage() async {
    if (_profileImage != null) {
      final fileName = currentUser.email! + '_profile_image';
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images/$fileName.jpg');
      await ref.putFile(_profileImage!);
      final downloadUrl = await ref.getDownloadURL();

      // Save the download URL in Firestore
      await userCollection.doc(currentUser.email).update({'profileImage': downloadUrl});

      return downloadUrl;
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

  void viewProfileImage() {
    if (_profileImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(image: _profileImage!),
        ),
      );
    }
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
            .collection("UsersProfile")
            .doc(currentUser.email)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final profileImageUrl = userData['profileImage'];

            return ListView(
              children: [
                SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Profile Picture"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Update'),
                              onTap: () {
                                Navigator.pop(context);
                                editField('profileImage');
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.visibility),
                              title: Text('View'),
                              onTap: () {
                                Navigator.pop(context);
                                viewProfileImage();
                              },
                            ),
                             ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Remove'),
                                onTap: () {
                                Navigator.pop(context);
                                removeImage();
                          }
                             )
                          ],
                        ),
                      ),
                    );
                  },
                  child:   profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(profileImageUrl),
                  )
                      : Icon(
                    Icons.person,
                    size: 72,
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

// FullScreenImageView widget
class FullScreenImageView extends StatelessWidget {
  final File image;

  FullScreenImageView({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Picture'),
      ),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}
