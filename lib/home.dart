import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        'Likes': [],
      });


      textController.clear();
    }
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
                // Navigate to about page
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

            ),ListTile(
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
                // Navigate to about page
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ));
              },

            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('PostOpportunityPage'),
              onTap: () {
                // Navigate to about page
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostOpportunityPage(),
                ));
              },

            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Navigate to about page
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AboutPage(),
                ));
              },

            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ));
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
