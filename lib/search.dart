import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_ngo_app/profile_page.dart';

import 'chat_page.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Map<String, dynamic>? userMap; // Make userMap nullable

  bool isLoading = false;
  final TextEditingController _search = TextEditingController();

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
      userMap = null; // Reset userMap before searching
    });

    final querySnapshot = await _firestore
        .collection('Users')
        .where('email', isEqualTo: _search.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        userMap = querySnapshot.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('User Search'),
      ),
      body: isLoading
          ? Center(
        child: Container(
          height: size.height / 20,
          width: size.width / 20,
          child: CircularProgressIndicator(),
        ),
      )
          : Column(
        children: [
          SizedBox(height: size.height / 20),
          Container(
            height: size.height / 14,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 14,
              width: size.width / 1.15,
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: size.height / 50),
          ElevatedButton(onPressed: onSearch, child: Text('Search')),
          if (userMap != null)
            ListTile(
              onTap: () {
                // Handle the tap on the search result here
                Navigator.of(context).push
                  (MaterialPageRoute(
                  builder: (context)=>ProfilePage(),
                ));
              },
              title: Text(userMap!['email']),
            ),
        ],
      ),
    );
  }
}