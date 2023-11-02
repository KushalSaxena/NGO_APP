import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostOpportunityPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final User currentUser = FirebaseAuth.instance.currentUser!;

  void _postOpportunity(BuildContext context) async {
    String name = nameController.text;
    String description = descriptionController.text;

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("VolunteerOpportunities").add({
      'name': name,
      'description': description,
      // Add any additional fields you may need
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Opportunity posted successfully!"),
        duration: Duration(seconds: 3),
      ),
    );

    // Clear the text fields after posting
    nameController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Volunteer Opportunity"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Opportunity Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _postOpportunity(context),
              child: Text("Post Opportunity"),
            ),
          ],
        ),
      ),
    );
  }
}
