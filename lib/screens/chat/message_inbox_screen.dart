import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping/screens/chat/search_user_screen.dart';
import 'package:shopping/widgets/chat/message_list.dart';
import '../../widgets/chat/message_list.dart';

class MessageInboxScreen extends StatefulWidget {
  static const routeName = '/message_inbox_screen';

  @override
  _MessageInboxScreenState createState() => _MessageInboxScreenState();
}

class _MessageInboxScreenState extends State<MessageInboxScreen> {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference userList = FirebaseFirestore.instance.collection('users');

  var userData;
  var userStatus;
  bool _isLoading = false;

  CollectionReference usersList =
      FirebaseFirestore.instance.collection('users');
  void initState() {
    updateUserCurrentScreen();
    fetchUserData();

    super.initState();
  }

  Future<void> fetchUserData() async {
    _isLoading = true;
    userData = await userList.doc(user.uid).get().then((value) {
      userStatus = value['status'];

      setState(() {
        _isLoading = false;
      });
    });
  }

  void updateUserCurrentScreen() async {
    usersList.doc(user.uid).update({
      'chattingWith': "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Inbox'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'REMINDER!',
                  ),
                  content: Text(
                    'Please note that all chat data are being monitored. Do you want to proceed?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop(false);
                        Navigator.of(context)
                            .pushNamed(SearchUserScreen.routeName);
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop(false);
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: userStatus == 'admin'
                  ? FirebaseFirestore.instance
                      .collection('chatRooms')
                      // .where('participants', arrayContains: user.uid)
                      .orderBy('lastMessageAt', descending: true)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('chatRooms')
                      .where('participants', arrayContains: user.uid)
                      .orderBy('lastMessageAt', descending: true)
                      .snapshots(),
              builder: (ctx, inboxSnapshot) {
                if (inboxSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final inboxDocs = inboxSnapshot.data.docs;

                if (inboxDocs.length > 0) {
                  return ListView.builder(
                      itemCount: inboxDocs.length,
                      itemBuilder: (_, i) {
                        if (inboxDocs[i]['lastMessageAt'] != "") {
                          int index = 0;
                          if (user.uid == inboxDocs[i]['participants'][0]) {
                            index = 1;
                          }
                          var chatPartnerId =
                              inboxDocs[i]['participants'][index];
                          var forAdmin =
                              inboxDocs[i]['participants'][1 - index];
                          return Column(
                            children: [
                              MessageList(
                                forAdmin,
                                chatPartnerId,
                                inboxDocs[i].id,
                                inboxDocs[i]['lastMessage'],
                                inboxDocs[i]['lastMessageAt'],
                                inboxDocs[i]['lastMessageFrom'],
                                inboxDocs[i]['readByRecipient'],
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      });
                } else {
                  return Container();
                }
              },
            ),
    );
  }
}
