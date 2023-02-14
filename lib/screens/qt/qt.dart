import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QTtile extends StatefulWidget {
  final String qtId;
  final String tileId;
  final String initial;
  final String title;
  final String content;
  final String creatorId;

  QTtile(
    this.qtId,
    this.tileId,
    this.initial,
    this.title,
    this.content,
    this.creatorId,
  );

  // const QTtile({Key key}) : super(key: key);

  @override
  State<QTtile> createState() => _QTtileState();
}

class _QTtileState extends State<QTtile> {
  bool _expanded = false;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          // minVerticalPadding: 10,
          leading: CircleAvatar(
            child: Text(widget.initial),
            backgroundColor: Colors.indigo.shade100,
          ),
          title: Text(widget.title),

          trailing: currentUser.uid == widget.creatorId
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'Are you sure?',
                          ),
                          content: Text(
                            'Do you want to remove your post?',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(false);
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop(false);

                                await FirebaseFirestore.instance
                                    .collection('qt')
                                    .doc(widget.qtId)
                                    .collection('qts')
                                    .doc(widget.tileId)
                                    .delete();
                              },
                              child: Text('Confirm'),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                )
              : IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
        ),
        _expanded
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SelectableText(widget.content),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
