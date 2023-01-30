import 'package:flutter/material.dart';

class QTtile extends StatefulWidget {
  final String initial;
  final String title;
  final String content;

  QTtile(
    this.initial,
    this.title,
    this.content,
  );

  // const QTtile({Key key}) : super(key: key);

  @override
  State<QTtile> createState() => _QTtileState();
}

class _QTtileState extends State<QTtile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: () {
            setState(() {
              _expanded = true;
            });
          },
          // minVerticalPadding: 10,
          leading: CircleAvatar(
            child: Text(widget.initial),
            backgroundColor: Colors.indigo.shade100,
          ),
          title: Text(widget.title),
          trailing: IconButton(
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
                    child: Text(widget.content),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
