import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import './message_item.dart';
import 'package:shopping/screens/chat/chat_screen.dart';

//Call from message inbox screeen
class MessageList extends StatefulWidget {
  final String forAdmin;
  final String senderId;
  final String chatRoomId;
  final String lastMesssage;
  final String lastMessageAt;
  final String lastMessageFrom;
  final bool readByRecipient;

  MessageList(
    this.forAdmin,
    this.senderId,
    this.chatRoomId,
    this.lastMesssage,
    this.lastMessageAt,
    this.lastMessageFrom,
    this.readByRecipient,
  );

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference userList = FirebaseFirestore.instance.collection('users');

  var userData;
  var userStatus;
  var forAdminName;
  bool _isLoading = false;

  CollectionReference usersList =
      FirebaseFirestore.instance.collection('users');
  void initState() {
    fetchUserData();

    super.initState();
  }

  Future<void> fetchUserData() async {
    _isLoading = true;

    userData = await userList.doc(user.uid).get().then((value) async {
      userStatus = value['status'];
      var forAdminData =
          await userList.doc(widget.forAdmin).get().then((value) {
        forAdminName = value['firstName'];
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('im in message item' + senderId);
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.senderId)
                .snapshots(),
            builder: (ctx, senderSnapshot) {
              if (senderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final senderDocs = senderSnapshot.data.data();

              if (senderDocs != null) {
                String username = senderDocs['firstName'];
                String imageUrl = senderDocs['imageUrl'];
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: ListTile(
                      tileColor: Theme.of(context).accentColor,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userStatus == 'admin'
                                ? forAdminName + ' & ' + username
                                : username,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            widget.lastMesssage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // leading: CircleAvatar(
                      //   backgroundImage: imageUrl != null
                      //       ? imageUrl != ''
                      //           ? NetworkImage(imageUrl)
                      //           : null
                      //       : null,
                      // ),
                      trailing: Text(widget.lastMessageAt.substring(11, 16)),
                      onTap: () => Navigator.of(context).pushNamed(
                          ChatScreen.routeName,
                          arguments: [widget.senderId, widget.chatRoomId])),
                );
              } else {
                return Container();
              }
            });
  }
}
