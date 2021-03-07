import 'package:flutter/material.dart';

class AddTrack extends StatefulWidget {
  @override
  _AddTrackState createState() => _AddTrackState();
}

class _AddTrackState extends State<AddTrack> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Gps-Track"),
      ),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
