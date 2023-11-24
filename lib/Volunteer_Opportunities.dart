import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerOpportunities extends StatefulWidget {
  @override
  _VolunteerOpportunitiesState createState() => _VolunteerOpportunitiesState();
}

class _VolunteerOpportunitiesState extends State<VolunteerOpportunities> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Opportunities"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Opportunities").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var opportunities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: opportunities.length,
            itemBuilder: (context, index) {
              var opportunity = opportunities[index];
              var opportunityData = opportunity.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(opportunityData['OpportunityName']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opportunityData['OpportunityDescription']),
                    Text("Posted by: ${opportunityData['UserEmail']}"),
                    Text("Posted on: ${formatDate(opportunityData['TimeStamp'].toDate())}"),
                  ],
                ),
                trailing: FutureBuilder<bool>(
                  future: checkIfAlreadyApplied(opportunity.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    return ElevatedButton(
                      onPressed: snapshot.data! ? null : () => applyToOpportunity(opportunity.id, opportunityData['UserEmail']),
                      child: Text(snapshot.data! ? "Already Applied" : "Apply"),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> checkIfAlreadyApplied(String opportunityId) async {
    var applicationQuery = await FirebaseFirestore.instance
        .collection("Applications")
        .where('OpportunityId', isEqualTo: opportunityId)
        .where('ApplicantEmail', isEqualTo: currentUser.email)
        .get();

    return applicationQuery.docs.isNotEmpty;
  }

  void applyToOpportunity(String opportunityId, String opportunityOwnerEmail) async {
    // Add logic to store application data in Firestore
    await FirebaseFirestore.instance.collection("Applications").add({
      'OpportunityId': opportunityId,
      'ApplicantEmail': currentUser.email,
      'OpportunityOwnerEmail': opportunityOwnerEmail,
      'Status': 'Pending', // You can set an initial status or handle it dynamically
      'TimeStamp': Timestamp.now(),
    });

    // Optionally, you can provide feedback to the user after applying.

    // You might also want to update the UI to reflect the application status.
    setState(() {
      // Trigger a rebuild to update the button text
    });
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
