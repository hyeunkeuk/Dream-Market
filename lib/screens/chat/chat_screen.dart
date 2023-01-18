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

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser;
  var toId;
  var _isInit = true;
  var _isLoading = true;

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
  AppLifecycleState _notification;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        updateUserCurrentScreen();
        break;
      case AppLifecycleState.inactive:
        updateUserCurrentScreenToNull();
        break;
      case AppLifecycleState.paused:
        updateUserCurrentScreenToNull();
        break;
      case AppLifecycleState.detached:
        updateUserCurrentScreenToNull();
        break;
    }
    // setState(() {
    //   _notification = state;
    // });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      var chatData = ModalRoute.of(context).settings.arguments as List;
      toId = chatData[0];
      if (chatData[1] == "") {
        await createChatRoom();
      } else {
        chatRoomId = chatData[1];
      }
      updateUserCurrentScreen();

      fetchDatabaseList();

      // getRoomId();

    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void updateUserCurrentScreen() async {
    usersList.doc(user.uid).update({
      'chattingWith': toId,
    });
  }

  void updateUserCurrentScreenToNull() async {
    usersList.doc(user.uid).update({
      'chattingWith': "",
    });
  }

  void createChatRoom() async {
    var chatRoom = await chatRooms.add({
      'participants': [user.uid, toId],
      'roomParticipants': ['${user.uid}_${toId}', '${toId}_${user.uid}'],
      'readByRecipient': false,
      'lastMessage': "",
      'lastMessageAt': "",
      'lastMessageFrom': "",
    });
    chatRoomId = chatRoom.id;
  }

  void fetchDatabaseList() async {
    // _isLoading = true;

    dynamic resultant = await fetchUserData().then((value) {
      if (value == null) {
        print('Unable to retrieve');
      } else {
        setState(() {
          chatPartnerData = value;
          _isLoading = false;
        });
      }
    });
  }

  Future fetchUserData() async {
    // _isLoading = true;
    try {
      return await usersList.doc(toId).get();
    } catch (error) {
      print('im in message_bubble' + error.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await updateUserCurrentScreenToNull();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () async {
              await updateUserCurrentScreenToNull();
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: _isLoading
              ? CircularProgressIndicator()
              : Row(
                  children: [
                    // CircleAvatar(
                    //   backgroundImage: chatPartnerData['imageUrl'] != ""
                    //       ? NetworkImage(chatPartnerData['imageUrl'])
                    //       : null,
                    // ),
                    Text('${chatPartnerData['firstName']}'),
                  ],
                ),
          // title: Text('chat'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Messages(chatRoomId, chatPartnerData['firstName']),
              ),
              NewMessage(toId),
            ],
          ),
        ),
      ),
    );
  }
}
