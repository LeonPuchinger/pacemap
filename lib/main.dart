import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pacemap/data/services/database.dart';
import 'package:pacemap/widgets/addtrack.dart';
import 'package:pacemap/widgets/tracklist.dart';

void main() {
  GetIt.I.registerLazySingletonAsync<DatabaseHandler>(
    () => DatabaseHandler.initDatabase(),
    dispose: (db) => db.dispose(),
  );
  runApp(PaceMapApp());
}

class PaceMapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaceMap',
      theme: ThemeData.dark(),
      initialRoute: "list",
      routes: {
        "list": (_) => Tracklist(),
        "list/add": (_) => AddTrack(),
      },
      builder: (_, route) {
        return FutureBuilder(
          future: GetIt.I.allReady(),
          builder: (_, readySnapshot) {
            if (readySnapshot.hasData) {
              return route!;
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      },
    );
  }
}
