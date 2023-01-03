import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/chat/message.dart';
import '../../widgets/chat/new_message.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chatSreen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final user = FirebaseAuth.instance.currentUser;
  var toId;
  var _isInit = true;
  var isLoading = false;

  var chatRoomId;
  var chatPartnerData;

  CollectionReference chatRooms =
      FirebaseFirestore.instance.collection('chatRooms');
  CollectionReference usersList =
      FirebaseFirestore.instance.collection('users');

  // @override
  // void initState() {
  //   var chatData = ModalRoute.of(context).settings.arguments as List;
  //   toId = chatData[0];
  //   chatRoomId = chatData[1];
  //   fetchDatabaseList();

  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      var chatData = ModalRoute.of(context).settings.arguments as List;
      toId = chatData[0];
      chatRoomId = chatData[1];
      fetchDatabaseList();
      // getRoomId();

    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void fetchDatabaseList() async {
    isLoading = true;

    dynamic resultant = await fetchUserData().then((value) {
      if (value == null) {
        print('Unable to retrieve');
      } else {
        setState(() {
          chatPartnerData = value;
          isLoading = false;
        });
      }
    });
  }

  Future fetchUserData() async {
    isLoading = true;
    try {
      return await usersList.doc(toId).get();
    } catch (error) {
      print('im in message_bubble' + error.toString());
      return null;
    }
  }

  Future getUserData() async {
    isLoading = true;

    return await usersList.doc(toId).get();
  }

  // void getRoomId() async {
  //   await chatRooms
  //       .where('roomParticipants',
  //           arrayContainsAny: ['${user.uid}_${toId}', '${toId}_${user.uid}'])
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //         querySnapshot.docs.forEach((doc) {
  //           chatRoomId = doc.id;
  //         });
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: isLoading
            ? CircularProgressIndicator()
            : Row(
                children: [
                  CircleAvatar(
                    backgroundImage: chatPartnerData['imageUrl'] != ""
                        ? NetworkImage(chatPartnerData['imageUrl'])
                        : null,
                  ),
                  Text('  ${chatPartnerData['firstName']}'),
                ],
              ),
        // title: Text('chat'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Messages(chatRoomId, chatPartnerData['firstName']),
            ),
            NewMessage(toId),
          ],
        ),
      ),
    );
  }
}
