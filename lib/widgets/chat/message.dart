import './message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Call from ChatScreen
class Messages extends StatefulWidget {
  final String chatRoomId;
  final String chatPartnerName;
  Messages(
    this.chatRoomId,
    this.chatPartnerName,
  );

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final user = FirebaseAuth.instance.currentUser;

  var chatMesssages = [];

  CollectionReference chatRooms =
      FirebaseFirestore.instance.collection('chatRooms');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .orderBy('sentAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (chatSnapshot.connectionState == ConnectionState.active) {
          var chatDocs = chatSnapshot.data.docs;

          if (chatDocs.isNotEmpty) {
            return ListView.builder(
              reverse: true,
              itemCount: chatDocs.length,
              itemBuilder: (ctx, index) {
                return MessageBubble(
                  chatDocs[index]['message'],
                  chatDocs[index]['sentBy'], //sender.id
                  chatDocs[index]['sentAt'],
                  widget.chatPartnerName,
                  chatDocs[index]['sentBy'] == user.uid,
                );
              },
            );
          } else {
            return Container();
          }
        } else {
          print(chatSnapshot.connectionState);

          return Container();
        }
      },
    );
  }
}
