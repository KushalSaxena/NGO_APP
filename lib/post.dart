import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:major_ngo_app/comments.dart';
import 'package:major_ngo_app/helper/helper_methods.dart';
import 'package:major_ngo_app/comment_button.dart';
import 'package:major_ngo_app/like_button.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final String? imageUrl;
  final Key? key;

  const Post({
    this.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    this.imageUrl,

  });

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document in the Firebase
    DocumentReference postRef =
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // If the post is now liked, add the user email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // If the post is now unliked, remove the user email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(),
    });
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Write a comment.."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message
          Text(
            widget.message,
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              // User
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                " . ",
                style: TextStyle(color: Colors.grey[400]),
              ),
              // Time
              Text(
                widget.time,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Like Button
              Column(
                children: [
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(width: 10),
              // Comment Button
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  SizedBox(height: 5),
                  Text(
                    '0', // You can display the actual comment count here
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),
          if (widget.imageUrl != null)
            Center(
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                height: 200,
                width: 200,
              ),
            ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;

                  return Comments(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

