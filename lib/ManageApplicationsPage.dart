import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageApplicationsPage extends StatefulWidget {
  @override
  _ManageApplicationsPageState createState() => _ManageApplicationsPageState();
}

class _ManageApplicationsPageState extends State<ManageApplicationsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Applications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Opportunities").where('UserEmail', isEqualTo: currentUser.email).snapshots(),
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

              return Column(
                children: [
                  ListTile(
                    title: Text(opportunityData['OpportunityName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opportunityData['OpportunityDescription']),
                        Text("Posted on: ${formatDate(opportunityData['TimeStamp'].toDate())}"),
                      ],
                    ),
                  ),
                  ApplicationsList(opportunityId: opportunity.id),
                  Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}

class ApplicationsList extends StatelessWidget {
  final String opportunityId;

  const ApplicationsList({required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Applications").where('OpportunityId', isEqualTo: opportunityId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var applications = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            var application = applications[index];
            var applicationData = application.data() as Map<String, dynamic>;

            return ListTile(
              title: Text("Applicant: ${applicationData['ApplicantEmail']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status: ${applicationData['Status']}"),
                  Text("Applied on: ${formatDate(applicationData['TimeStamp'].toDate())}"),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  showUpdateStatusDialog(context, opportunityId, application.id, applicationData['Status']);
                },
                child: Text("Update Status"),
              ),
            );
          },
        );
      },
    );
  }

  void showUpdateStatusDialog(BuildContext context, String opportunityId, String applicationId, String currentStatus) {
    String newStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Application Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current Status: $currentStatus"),
            DropdownButton<String>(
              value: newStatus,
              onChanged: (String? value) {
                if (value != null) {
                  newStatus = value;
                }
              },
              items: ["Pending", "Approved", "Rejected"].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Update the status in Firestore
              await FirebaseFirestore.instance.collection("Applications").doc(applicationId).update({'Status': newStatus});

              Navigator.pop(context);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
