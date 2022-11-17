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
    final user = await FirebaseAuth.instance.currentUser;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    var chatRef = await FirebaseFirestore.instance.collection('chats')
        // .doc(user.uid)
        // .collection(widget.toId)
        .add(
      {
        'participants': [user.uid, widget.toId], //[sender.id, recipient.id]
        'message': _enteredMessage,
        'createdAt': Timestamp.now(),
        'fromId': user.uid,
        'toId': widget.toId,
        // 'username': userdata['username'],
        // 'userImage': userdata['imageUrl'],
      },
    );
    FirebaseFirestore.instance
        .collection('chatsCollectionByUser')
        .doc(user.uid)
        .collection(widget.toId)
        .add({'messageId': chatRef.id});
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
