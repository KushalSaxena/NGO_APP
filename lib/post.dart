import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_ngo_app/like_button.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final Key? key;

  const Post({
    this.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState(){
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike(){
    setState(() {
      isLiked = !isLiked;
    });

    //Access the document in the firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if(isLiked){
      // if the post if now liked, add the user email to the 'Likes' field
      postRef.update({
        'Likes' :  FieldValue.arrayUnion([currentUser.email])
      });
    }else{
      // if the post is now unliked, remove the user email from the 'Likes' field
      postRef.update({
        'Likes' :  FieldValue.arrayRemove([currentUser.email])
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          Column(
            children: [
              //like button
              LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLike),
              const SizedBox(height: 5,),
              ////like count
              Text(
                widget.likes.length.toString(),
                style: TextStyle(color: Colors.grey),),

            ],
          ),
          const SizedBox(width: 20,),
          Expanded( // Ensure the message takes up all available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.message,
                  // Ensure the text has a visible color
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
