import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './message_item.dart';
import 'package:shopping/screens/chat/chat_screen.dart';

// import 'package:provider/provider.dart';

// import '../screens/edit_product_screen.dart';
// import '../providers/products.dart';
// import 'dart:io';

//Call from message inbox screeen
class MessageList extends StatelessWidget {
  final String senderId;
  MessageList(this.senderId);

  @override
  Widget build(BuildContext context) {
    // print('im in message item' + senderId);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .snapshots(),
        builder: (ctx, senderSnapshot) {
          if (senderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final senderDocs = senderSnapshot.data.data();

          if (senderDocs != null) {
            String username = senderDocs['username'];
            String imageUrl = senderDocs['imageUrl'];
            return ListTile(
                title: Text(username),
                leading: CircleAvatar(
                  backgroundImage: imageUrl != null
                      ? imageUrl != ''
                          ? NetworkImage(imageUrl)
                          : null
                      : null,
                ),
                onTap: () => Navigator.of(context)
                    .pushNamed(ChatScreen.routeName, arguments: senderId));
          } else {
            return Container();
          }
        });
  }
}
