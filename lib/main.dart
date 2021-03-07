import 'package:flutter/material.dart';
import 'package:pacemap/widgets/tracklist.dart';

void main() => runApp(PaceMapApp());

class PaceMapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaceMap',
      theme: ThemeData.dark(),
      initialRoute: "list",
      routes: {
        "list": (_) => Tracklist(),
      },
    );
  }
}
