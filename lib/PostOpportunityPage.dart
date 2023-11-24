import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostOpportunityPage extends StatefulWidget {
  @override
  _PostOpportunityPageState createState() => _PostOpportunityPageState();
}

class _PostOpportunityPageState extends State<PostOpportunityPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _opportunityNameController = TextEditingController();
  final _opportunityDescriptionController = TextEditingController();

  void postOpportunity(BuildContext context) async {
    String opportunityName = _opportunityNameController.text.trim();
    String opportunityDescription = _opportunityDescriptionController.text.trim();

    if (opportunityName.isNotEmpty && opportunityDescription.isNotEmpty) {
      FirebaseFirestore.instance.collection("Opportunities").add({
        'OpportunityName': opportunityName,
        'OpportunityDescription': opportunityDescription,
        'UserEmail': currentUser.email,
        'TimeStamp': Timestamp.now(),
      });

      _opportunityNameController.clear();
      _opportunityDescriptionController.clear();

      // Show a success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Opportunity successfully posted!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Opportunity"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _opportunityNameController,
              decoration: InputDecoration(
                labelText: 'Opportunity Name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _opportunityDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Opportunity Description',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => postOpportunity(context),
              child: Text("Post Opportunity"),
            ),
          ],
        ),
      ),
    );
  }
}
