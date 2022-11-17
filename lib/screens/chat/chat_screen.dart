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
  var toId;
  var _isInit = true;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      toId = ModalRoute.of(context).settings.arguments as String;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Chat'),
        // actions: [
        //   DropdownButton(
        //     icon: Icon(
        //       Icons.more_vert,
        //       color: Theme.of(context).primaryIconTheme.color,
        //     ),
        //     items: [
        //       DropdownMenuItem(
        //         child: Container(
        //           child: Row(
        //             // mainAxisAlignment: MainAxisAlignment.center,
        //             mainAxisSize: MainAxisSize.min,
        //             children: <Widget>[
        //               Icon(
        //                 Icons.exit_to_app,
        //                 color: Theme.of(context).primaryColor,
        //               ),
        //               SizedBox(width: 8),
        //               Text('Logout'),
        //               // Padding(padding: EdgeInsets.all(10))
        //             ],
        //           ),
        //           // width: 15,
        //         ),
        //         value: 'logout',
        //       ),
        //     ],
        //     onChanged: (itemIdentifier) {
        //       if (itemIdentifier == 'logout') {
        //         FirebaseAuth.instance.signOut();
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              // child: Text('hi'),
              child: Messages(toId),
            ),
            NewMessage(toId),
            Divider(),
          ],
        ),
      ),
    );
  }
}
