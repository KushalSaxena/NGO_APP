import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageApplicationsPage extends StatelessWidget {
  final String opportunityId;
  final String opportunityName;

  ManageApplicationsPage({required this.opportunityId, required this.opportunityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Applications "),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("VolunteerApplications")
            .where('opportunityId', isEqualTo: opportunityId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No applications available  '),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final application = snapshot.data!.docs[index];
              return ListTile(
                title: Text(application['userId']),
                subtitle: Text(application['status']),
              );
            },
          );
        },
      ),
    );
  }
}
