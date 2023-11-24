import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicationStatusPage extends StatefulWidget {
  @override
  _ApplicationStatusPageState createState() => _ApplicationStatusPageState();
}

class _ApplicationStatusPageState extends State<ApplicationStatusPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Application Status"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Applications").where('ApplicantEmail', isEqualTo: currentUser.email).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var applications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              var application = applications[index];
              var applicationData = application.data() as Map<String, dynamic>;

              return ListTile(
                title: Text("Opportunity: ${applicationData['OpportunityId']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status: ${applicationData['Status']}"),
                    Text("Applied on: ${formatDate(applicationData['TimeStamp'].toDate())}"),
                  ],
                ),
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
