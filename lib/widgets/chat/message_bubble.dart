import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class MessageBubble extends StatefulWidget {
  MessageBubble(
    this.message,
    this.senderId,
    this.recipientId,
    this.isMe,
  );

  final String message;
  final String senderId;
  final String recipientId;
  final bool isMe;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final CollectionReference usersList =
      FirebaseFirestore.instance.collection('users');

  // List userProfileList;

  var isLoading = false;
  var userData;

  @override
  void initState() {
    super.initState();
    fetchDatabaseList();
  }

  fetchDatabaseList() async {
    isLoading = true;

    dynamic resultant = await fetchUserData();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        userData = resultant;
        isLoading = false;
      });
    }
  }

  Future fetchUserData() async {
    isLoading = true;
    try {
      return await usersList.doc(widget.senderId).get();
    } catch (error) {
      print('im in message_bubble' + error.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    // print('im in message bubble');
    return isLoading
        ? widget.isMe
            ? const Center(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CircularProgressIndicator(),
                ),
              )
            : const Center(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircularProgressIndicator(),
                ),
              )
        : Stack(
            children: [
              Row(
                mainAxisAlignment: widget.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Theme.of(context).accentColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: !widget.isMe
                              ? Radius.circular(0)
                              : Radius.circular(12),
                          bottomRight: widget.isMe
                              ? Radius.circular(0)
                              : Radius.circular(12),
                        ),
                      ),
                      width: 140,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(userData['username'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.isMe
                                      ? Colors.white
                                      : Colors.black)),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.isMe
                                  ? Theme.of(context)
                                      .accentTextTheme
                                      .headline1
                                      .color
                                  : Colors.black,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
              Positioned(
                top: -10,
                left: widget.isMe ? null : 120,
                right: widget.isMe ? 120 : null,
                child: CircleAvatar(
                  backgroundImage: userData['imageUrl'] != ""
                      ? NetworkImage(userData['imageUrl'])
                      : null,
                ),
              ),
            ],
            clipBehavior: Clip.none,
          );
  }
}
