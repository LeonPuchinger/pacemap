import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:latlng/latlng.dart';
import 'package:pacemap/data/services/database.dart';
import 'package:pacemap/data/services/filesystem.dart';
import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/state/appBloc.dart';
import 'package:rxdart/rxdart.dart';

class MapBloc with TimeValidator {
  final _appBloc = GetIt.I<AppBloc>();
  final _db = GetIt.I<DatabaseHandler>();

  final _track = BehaviorSubject<GpsTrack>();
  final _gpx = BehaviorSubject<List<LatLng>>();
  final _startTime = BehaviorSubject<String>();
  final _initialTime = BehaviorSubject<DateTime>();

  Stream<GpsTrack> get track => _track.stream;
  Stream<List<LatLng>> get gpx => _gpx.stream;
  Stream<DateTime> get startTime => _startTime.transform(timeValidator);
  Stream<DateTime> get initialTime => _initialTime.stream;

  late StreamSubscription selectedTrackSubscription;

  Function(String) get setStartTime => _startTime.add;

  MapBloc() {
    init();
  }

  init() {
    selectedTrackSubscription = _appBloc.selectedTrack.listen((track) async {
      _track.add(track);
      final gpx = await readGpx(track.id);
      _gpx.add(gpx);
      if (track.startTime != null) {
        _initialTime.add(track.startTime!);
      }
    });
    startTime.listen((time) {
      final track = _track.value!;
      _track.add(track..startTime = time);
    });
    track.listen((track) {
      _db.insertTrack(track);
    });
  }

  dispose() {
    _track.close();
    _gpx.close();
    _startTime.close();
    _initialTime.close();
    selectedTrackSubscription.cancel();
  }
}

mixin TimeValidator {
  final timeValidator = StreamTransformer<String, DateTime>.fromHandlers(
      handleData: (time, sink) {
    var dateTime = DateTime.tryParse(time);
    if (dateTime != null) {
      sink.add(dateTime);
      return;
    }
    final simpleTime = r"([01]\d|2[0-3]):([0-5]\d)";
    final rSimpleTime = RegExp(simpleTime);
    if (rSimpleTime.hasMatch(time)) {
      final match = rSimpleTime.firstMatch(time)!;
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      int day, month, year;
      final simpleDateTime =
          r"(3[01]|[12][0-9]|0?[1-9])\.(1[012]|0?[1-9])\.([2-9][0-9]{3})";
      final rSimpleDateTime = RegExp(simpleDateTime);
      if (rSimpleDateTime.hasMatch(time)) {
        final match = rSimpleDateTime.firstMatch(time)!;
        day = int.parse(match.group(1)!);
        month = int.parse(match.group(2)!);
        year = int.parse(match.group(3)!);
      } else {
        final today = DateTime.now();
        day = today.day;
        month = today.month;
        year = today.year;
      }
      dateTime = DateTime(year, month, day, hour, minute);
      sink.add(dateTime);
      return;
    }
    sink.addError("Invalid time format");
  });
}
