import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final TextEditingController field1Controller = TextEditingController();
  final TextEditingController field2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: field1Controller,
              maxLines: 5, // Set max lines to 5 for a larger input area
              decoration: InputDecoration(
                labelText: 'App description:',
                hintText: 'An social app that connects through various NGOs as per the services and needs',
                border: OutlineInputBorder(), // Add border for a clear text input area
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: field2Controller,
              maxLines: 7, // Set max lines to 7 for a larger input area
              decoration: InputDecoration(
                labelText: 'Developers:',
                hintText: 'Kushal Saxena - 20BCG1087\nPrakamya Verma - 20BCG1052\nAyush Nayak - 20BCG1127\nDev Sirohi - 20BCS3849',
                border: OutlineInputBorder(), // Add border for a clear text input area
              ),
            ),
          ],
        ),
      ),
    );
  }
}
