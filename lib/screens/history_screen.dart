import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history';
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Order History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) =>
                  dateCollection(),
            ),
    );
  }

  Widget dateCollection() {
    return ExpansionTile();
  }
}
