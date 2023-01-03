import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  final String toId;
  NewMessage(this.toId);
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    var chatRoomId;
    CollectionReference chatRooms =
        FirebaseFirestore.instance.collection('chatRooms');

    await chatRooms
        .where('roomParticipants', arrayContainsAny: [
          '${user.uid}_${widget.toId}',
          '${widget.toId}_${user.uid}'
        ])
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            chatRoomId = doc.id;
          });
        });

    if (chatRoomId == null) {
      var chatroom = await chatRooms.add({
        'participants': [user.uid, widget.toId],
        'roomParticipants': [
          '${user.uid}_${widget.toId}',
          '${widget.toId}_${user.uid}'
        ],
        'readByRecipient': false,
        'recentMessage': _enteredMessage,
      });
      chatRoomId = chatroom.id;
    } else {
      chatRooms.doc(chatRoomId).update({
        'recentMessage': _enteredMessage,
      });
    }
    chatRooms.doc(chatRoomId).collection('messages').add(
      {
        'message': _enteredMessage,
        'sentAt': Timestamp.now(),
        'sentBy': user.uid,
      },
    );

    // var chatRef = await FirebaseFirestore.instance
    //     .collection('messages')
    //     .doc(chatRoomId)
    //     .collection('messageTexts')
    //     .add(
    //   {
    //     'message': _enteredMessage,
    //     'sentAt': Timestamp.now(),
    //     'sentBy': user.uid,
    //   },
    // );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
              onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
              icon: Icon(
                Icons.send, color: Colors.black,
                // color: Theme.of(context).primaryColor,
              ))
        ],
      ),
    );
  }
}
