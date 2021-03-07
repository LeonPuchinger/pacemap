import 'package:flutter/material.dart';

class Tracklist extends StatefulWidget {
  @override
  _TracklistState createState() => _TracklistState();
}

class _TracklistState extends State<Tracklist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PaceMap"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Track"),
        icon: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, "list/add"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
