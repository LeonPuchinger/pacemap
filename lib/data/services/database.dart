import 'package:pacemap/data/services/gps.dart';
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

  Future open() async {
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

  Future insertTrack(GpsTrack track) async {
    final trackMap = {
      columnTrackId: track.id,
      columnTrackName: track.name,
      columnTrackDistance: track.distance,
      columnTrackUrl: track.thumbnailUrl,
      columnTrackStartTime: track.startTime?.toIso8601String(),
    };
    await db.insert(
      tableTracks,
      trackMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GpsTrack>> getTracks() async {
    final tracks = await db.query(tableTracks);
    return tracks.map((r) {
      return GpsTrack(
        r[columnTrackName] as String,
        r[columnTrackUrl] as String?,
        r[columnTrackStartTime] == null
            ? null
            : DateTime.tryParse(r[columnTrackStartTime] as String),
        r[columnTrackId] as int,
        r[columnTrackDistance] as int,
        TrackType.route,
      );
    }).toList();
  }

  Future dispose() async {
    await db.close();
  }
}
