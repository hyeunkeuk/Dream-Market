import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Calls from message_inbox_screen
class SearchUserScreen extends StatefulWidget {
  static const routeName = '/searchUserSreen';

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  var user = FirebaseAuth.instance.currentUser;

  final CollectionReference usersList =
      FirebaseFirestore.instance.collection('users');

  void updateUserCurrentScreen() async {
    usersList.doc(user.uid).update({
      'chattingWith': "",
    });
  }

  List userProfileList;

  var isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDatabaseList();
    updateUserCurrentScreen();
  }

  fetchDatabaseList() async {
    isLoading = true;

    dynamic resultant = await getUsersList();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        userProfileList = resultant;
        isLoading = false;
      });
    }
  }

  Future getUsersList() async {
    List itemList = [];
    try {
      await usersList.get().then((userListSnapshot) {
        userListSnapshot.docs.forEach((element) {
          if (user.uid != element.id) {
            itemList.add(element);
          }
        });
      });
      return itemList;
    } catch (error) {
      print('im in search user screen' + error.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Create Chat Room'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: ListView.builder(
                  itemCount: userProfileList.length,
                  itemBuilder: (ctx, index) {
                    var username = userProfileList[index].data()['firstName'] +
                        ' ' +
                        userProfileList[index].data()['lastName'];
                    var imageUrl = userProfileList[index].data()['imageUrl'];
                    var toId = userProfileList[index].id;
                    return Card(
                      child: ListTile(
                          title: Text(username),
                          // leading: CircleAvatar(
                          //   backgroundImage: imageUrl != null
                          //       ? imageUrl != ''
                          //           ? NetworkImage(imageUrl)
                          //           : null
                          //       : null,
                          // ),
                          onTap: () async {
                            CollectionReference chatRooms = FirebaseFirestore
                                .instance
                                .collection('chatRooms');
                            await chatRooms
                                .where('roomParticipants', arrayContainsAny: [
                                  '${user.uid}_${toId}',
                                  '${toId}_${user.uid}'
                                ])
                                .get()
                                .then((value) {
                                  Navigator.of(context).pushNamed(
                                      ChatScreen.routeName,
                                      arguments: [
                                        toId,
                                        value.docs.isEmpty
                                            ? ""
                                            : value.docs.first.id,
                                      ]);
                                });
                          }),
                    );
                  }),
            ),
    );
  }
}
