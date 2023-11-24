import 'package:flutter/material.dart';

class ProfilePictureViewPage extends StatelessWidget {
  final String imageUrl;

  const ProfilePictureViewPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Picture"),
      ),
      body: Center(
        child: Hero(
          tag: 'profileImage',
          child: imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
          )
              : Placeholder(), // or any other widget to indicate no image
        ),
      ),
    );
  }
}
