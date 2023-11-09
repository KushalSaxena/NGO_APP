import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:major_ngo_app/services/chat/chat_bubble.dart';
import 'package:major_ngo_app/services/chat/chat_service.dart';


class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final Chatservice _chatservice = Chatservice();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async{
    //only send message if there is something to send
    if(_messageController.text.isNotEmpty){
      await _chatservice.sendMessage(
          widget.receiverUserId,
          _messageController.text);
      _messageController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUserEmail),),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),

          _buildMessageInput(),

          const SizedBox(height: 25,),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList(){
    return StreamBuilder(
        stream: _chatservice.getMessage(
            widget.receiverUserId, _firebaseAuth.currentUser!.uid),
        builder: (context,snapshot){
          if(snapshot.hasError){
            return Text('Error${snapshot.error}');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Text('Loading..');
          }
          return ListView(
            reverse: true,
            children:
            snapshot.data!.docs.map((document)=>_buildMessageItem(document)).toList(),
          );
        });
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String,dynamic> data = document.data() as Map<String,dynamic>;

    //align the message to the right if the sender  is the current user ,otherwise to the left
    var alignment = (data['senderId']==_firebaseAuth.currentUser!.uid)
        ?Alignment.centerRight
        :Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
          (data['senderId']==_firebaseAuth.currentUser!.uid)
              ?CrossAxisAlignment.end
              :CrossAxisAlignment.start,
          mainAxisAlignment:
          (data['senderId']==_firebaseAuth.currentUser!.uid)
              ?MainAxisAlignment.end
              :MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5,),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter message',
                ),
              )
          ),


          //send button
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
            ),
          )
        ],
      ),
    );
  }
}