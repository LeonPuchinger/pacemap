import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AddTrack extends StatefulWidget {
  @override
  _AddTrackState createState() => _AddTrackState();
}

class _AddTrackState extends State<AddTrack> {
  final _showSearch = BehaviorSubject<bool>.seeded(false);

  @override
  void dispose() {
    _showSearch.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<bool>(
          stream: _showSearch.stream,
          initialData: false,
          builder: (_, showSearchSnapshot) {
            if (showSearchSnapshot.data!) {
              return TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search Gps-Tracks",
                  border: InputBorder.none,
                ),
              );
            } else {
              return Text("Add Gps-Track");
            }
          },
        ),
        actions: [
          StreamBuilder<bool>(
              stream: _showSearch.stream,
              initialData: false,
              builder: (_, showSearchSnapshot) {
                return IconButton(
                  icon: showSearchSnapshot.data!
                      ? Icon(Icons.close)
                      : Icon(Icons.search),
                  onPressed: () => _showSearch.add(!(showSearchSnapshot.data!)),
                );
              }),
        ],
      ),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
