import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pacemap/data/services/database.dart';
import 'package:pacemap/widgets/addtrack.dart';
import 'package:pacemap/widgets/tracklist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHandler.initDatabase();
  GetIt.I.registerSingleton<DatabaseHandler>(db);
  runApp(PaceMapApp());
}

class PaceMapApp extends StatefulWidget {
  @override
  _PaceMapAppState createState() => _PaceMapAppState();
}

class _PaceMapAppState extends State<PaceMapApp> {
  @override
  void dispose() {
    GetIt.I<DatabaseHandler>().dispose();
    super.dispose();
  }

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
    );
  }
}
