import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import '../../model/message.dart';

class Chatservice extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message)async{
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderId : currentUserId,
      senderEmail : currentUserEmail,
      receiverId : receiverId,
      timestamp : timestamp,
      message : message,
    );

    //construct chat room id from cureent user id & receiver id
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join(
        "_"
    );

    //add message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //Get messages
  Stream<QuerySnapshot> getMessage(String userId, String otherUserId){
    List<String> ids = [userId,otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp',descending: true)
        .snapshots();
  }
}