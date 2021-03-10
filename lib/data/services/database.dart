import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const tableTracks = "tracks";
const columnTrackId = "id";
const columnTrackName = "name";
const columnTrackDistance = "distance";
const columnTrackUrl = "url";
const columnTrackStartTime = "start";

class DatabaseHandler {
  late Database db;

  static Future<DatabaseHandler> initDatabase() async {
    final database = DatabaseHandler();
    await database.open();
    return database;
  }

  open() async {
    db = await openDatabase(
      join((await getApplicationDocumentsDirectory()).path, "pacemap.db"),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        create table $tableTracks (
          $columnTrackId integer primary key,
          $columnTrackName text not null,
          $columnTrackDistance integer not null,
          $columnTrackUrl text,
          $columnTrackStartTime text)
        ''');
      },
    );
  }
}
