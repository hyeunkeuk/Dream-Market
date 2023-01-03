import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class MessageBubble extends StatefulWidget {
  MessageBubble(
    this.message,
    this.senderId,
    this.sentAt,
    this.chatPartnerName,
    this.isMe,
  );

  final String message;
  final String senderId;
  final Timestamp sentAt;
  final String chatPartnerName;
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
    fetchDatabaseList();
    super.initState();
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
        : Column(
            children: [
              widget.isMe
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(widget.chatPartnerName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.isMe
                                    ? Colors.white
                                    : Color.fromARGB(255, 105, 10, 113))),
                      ),
                    ),
              Row(
                mainAxisAlignment: widget.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 200,
                      minWidth: 70,
                    ),
                    child: Container(
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
                        // width: 140,
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
                  ),
                ],
              ),
            ],
            // clipBehavior: Clip.none,
          );
  }
}
