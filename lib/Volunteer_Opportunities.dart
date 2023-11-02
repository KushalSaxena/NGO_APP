import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ManageApplicationsPage.dart';

class VolunteerOpportunities extends StatelessWidget {
  final User currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Opportunities"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("VolunteerOpportunities")
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
              child: Text('No volunteer opportunities available.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final opportunity = snapshot.data!.docs[index];
              return ListTile(
                title: Text(opportunity['name']),
                subtitle: Text(opportunity['description']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageApplicationsPage(
                          opportunityId: opportunity.id,
                          opportunityName: opportunity['name'],
                        ),
                      ),
                    );
                  },
                  child: Text("Apply"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: VolunteerOpportunities(),
));
