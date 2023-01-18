import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountDeletionRequestScreen extends StatefulWidget {
  static const routeName = '/AccountDeletionRequest';
  // const AccountDeletionRequestScreen({Key key}) : super(key: key);

  @override
  State<AccountDeletionRequestScreen> createState() =>
      _AccountDeletionRequestScreenState();
}

class _AccountDeletionRequestScreenState
    extends State<AccountDeletionRequestScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Requested Account Deletion'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('delete').snapshots(),
              builder: (ctx, inboxSnapshot) {
                if (inboxSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final inboxDocs = inboxSnapshot.data.docs;

                if (inboxDocs.length > 0) {
                  return ListView.builder(
                      itemCount: inboxDocs.length,
                      itemBuilder: (_, i) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                tileColor: Colors.red[200],
                                leading: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Requester: ${inboxDocs[i]['requesterName']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                                    Text(
                                      'ID: ${inboxDocs[i]['requesterId']}',
                                    ),
                                    Text(
                                      inboxDocs[i]['dateTime'].substring(0, 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                } else {
                  return Center(
                    child: Text('No Account Deletion Request'),
                  );
                }
              },
            ),
    );
  }
}
