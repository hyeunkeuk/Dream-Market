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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Inbox'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(SearchUserScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            // .where('participants', arrayContains: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, inboxSnapshot) {
          if (inboxSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final inboxDocs = inboxSnapshot.data.docs;
          // print('im in message inbox' + inboxDocs.toString());

          // print('im in message inbox screen' + inboxDocs[0].toString());

          // var senderData = FirebaseFirestore.instance
          //     .collection('users')
          //     .doc(senderId)
          //     .snapshots();

          var chatPartnerId;
          List<String> chatDictionary = [];
          if (inboxDocs.length > 0) {
            return ListView.builder(
                itemCount: inboxDocs.length,
                itemBuilder: (_, i) {
                  if (inboxDocs[i]['participants'].contains(user.uid)) {
                    int index = 0;

                    if (user.uid == inboxDocs[i]['participants'][0]) {
                      index = 1;
                    }
                    chatPartnerId = inboxDocs[i]['participants'][index];
                    if (chatDictionary.contains(chatPartnerId)) {
                      return Container();
                    } else {
                      chatDictionary.add(chatPartnerId);
                      return Column(
                        children: [
                          MessageList(chatPartnerId),
                          Divider(),
                        ],
                      );
                    }
                  } else {
                    return Container();
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
