import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot<Map<String, dynamic>>? _searchResults;

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      QuerySnapshot<Map<String, dynamic>> searchResults = await _firestore
          .collection("Users")
          .where("displayName", isGreaterThanOrEqualTo: query)
          .get();

      setState(() {
        _searchResults = searchResults;
      });
    } else {
      setState(() {
        _searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                labelText: 'Search Users',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          _searchResults != null
              ? Expanded(
            child: ListView(
              children: _searchResults!.docs
                  .map((doc) => ListTile(
                title: Text(doc["displayName"]),
                subtitle: Text(doc["email"]),
              ))
                  .toList(),
            ),
          )
              : Container(),
        ],
      ),
    );
  }
}
