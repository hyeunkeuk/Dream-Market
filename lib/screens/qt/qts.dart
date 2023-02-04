import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping/screens/qt/qt.dart';

class QTs extends StatefulWidget {
  final String qtId;

  QTs(
    this.qtId,
  );
  @override
  State<QTs> createState() => _QTsState();
}

class _QTsState extends State<QTs> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 500,
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('qt')
                  .doc(widget.qtId)
                  .collection('qts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, qtsSnapshot) {
                if (qtsSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (qtsSnapshot.connectionState ==
                    ConnectionState.active) {
                  var qtDocs = qtsSnapshot.data.docs;
                  if (qtDocs.isNotEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      // reverse: true,
                      itemCount: qtDocs.length,
                      itemBuilder: (ctx, index) {
                        // print(qtDocs[index]['creatorName']);

                        var initial =
                            qtDocs[index]['creatorName'].substring(0, 1);
                        var title = qtDocs[index]['title'];
                        var content = qtDocs[index]['content'];
                        var creatorId = qtDocs[index]['creatorId'];
                        var tileId = qtDocs[index].id;
                        return Column(
                          children: [
                            Divider(),
                            QTtile(
                              widget.qtId,
                              tileId,
                              initial,
                              title,
                              content,
                              creatorId,
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                } else {
                  // print(qtsSnapshot.connectionState);

                  return Container();
                }
              },
            ),
          );
  }
}
