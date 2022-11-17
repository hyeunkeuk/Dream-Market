import 'package:flutter/material.dart';
import 'package:shopping/screens/chat/chat_screen.dart';

class MessageItem extends StatelessWidget {
  dynamic sender;

  MessageItem(this.sender);

  @override
  Widget build(BuildContext context) {
    String username = sender['username'];
    String imageUrl = sender['imageUrl'];
    print(sender);
    return ListTile(
        title: Text(username),
        leading: CircleAvatar(
          backgroundImage: imageUrl != null
              ? imageUrl != ''
                  ? NetworkImage(imageUrl)
                  : null
              : null,
        ),
        onTap: () => Navigator.of(context)
            .pushNamed(ChatScreen.routeName, arguments: sender.uid));
  }
}
