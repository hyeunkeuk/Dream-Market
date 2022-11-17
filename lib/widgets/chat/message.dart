import './message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Call from ChatScreen
class Messages extends StatelessWidget {
  final String toId;
  Messages(this.toId);
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          // .where('participants', arrayContains: user.uid)
          // .where('toId', isEqualTo: toId)
          // .where('participants', arrayContains: toId)

          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // print('im in message' + chatSnapshot.toString());

        final chatDocs = chatSnapshot.data.docs;
        // print('im in message' + chatDocs.toString());

        if (chatDocs.isNotEmpty) {
          return ListView.builder(
              reverse: true,
              itemCount: chatDocs.length,
              itemBuilder: (ctx, index) {
                // print('im in message' + chatDocs.length.toString());
                if ((chatDocs[index]['fromId'] == user.uid &&
                        chatDocs[index]['toId'] == toId) ||
                    (chatDocs[index]['fromId'] == toId &&
                        chatDocs[index]['toId'] == user.uid)) {
                  return MessageBubble(
                    chatDocs[index]['message'],
                    chatDocs[index]['participants'][0], //sender.id
                    chatDocs[index]['participants'][1], //recipient.id
                    chatDocs[index]['participants'][0] == user.uid,
                  );
                } else {
                  return Container();
                }
              });
        } else {
          return Container();
        }
      },
    );
  }
}
