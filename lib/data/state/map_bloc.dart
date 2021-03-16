import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemap/data/services/database.dart';
import 'package:pacemap/data/services/filesystem.dart';
import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/services/map.dart';
import 'package:pacemap/data/services/validators.dart';
import 'package:pacemap/data/state/appBloc.dart';
import 'package:rxdart/rxdart.dart';

class MapBloc with TimeValidator {
  final _appBloc = GetIt.I<AppBloc>();
  final _db = GetIt.I<DatabaseHandler>();

  final _track = BehaviorSubject<GpsTrack>();
  final _gpx = BehaviorSubject<List<LatLng>>();
  final _startTime = BehaviorSubject<String>();
  final _initialTime = BehaviorSubject<DateTime>();
  final _athletes = BehaviorSubject<List<Athlete>>();

  Stream<GpsTrack> get track => _track.stream;
  Stream<List<LatLng>> get gpx => _gpx.stream;
  Stream<DateTime> get startTime => _startTime.transform(timeValidator);
  Stream<DateTime> get initialTime => _initialTime.stream;
  Stream<List<Athlete>> get athletes => _athletes.stream;

  late StreamSubscription selectedTrackSubscription;
  late StreamSubscription athleteAddedSubscription;

  Function(String) get setStartTime => _startTime.add;

  editAthlete(int index) {
    final athlete = _athletes.value![index];
    _appBloc.editAthlete(athlete);
  }

  deleteAthlete(int index) async {
    final athlete = _athletes.value![index];
    await _db.removeAthlete(athlete.id!);
    await updateAthletes();
  }

  updateAthletes() async {
    late StreamSubscription sub;
    sub = _track.listen((track) async {
      final athletes = await _db.getAthletes(track.id);
      _athletes.add(athletes);
      sub.cancel();
    });
  }

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
    athleteAddedSubscription = _appBloc.athleteAdded.listen((athlete) async {
      final track = _track.value!;
      await _db.insertAthlete(athlete, track.id);
      updateAthletes();
    });
    updateAthletes();
  }

  dispose() {
    _track.close();
    _gpx.close();
    _startTime.close();
    _initialTime.close();
    _athletes.close();
    selectedTrackSubscription.cancel();
    athleteAddedSubscription.cancel();
  }
}

class AddAthleteBloc with AthleteValidator {
  final _appBloc = GetIt.I<AppBloc>();

  String? latestName;
  Duration? latestPace;
  int? id;

  final _name = BehaviorSubject<String>();
  final _pace = BehaviorSubject<String>();
  final _initial = BehaviorSubject<Map<String, String>>();

  Stream<String> get name => _name.stream.transform(nameValidator);
  Stream<Duration> get pace => _pace.stream.transform(paceValidator);
  Stream<bool> get validated => CombineLatestStream.combine2(
        name,
        pace,
        (String n, Duration p) {
          latestName = n;
          latestPace = p;
          return true;
        },
      );
  Stream<Map<String, String>> get initial => _initial.stream;

  late StreamSubscription _athleteEditSubscription;

  Function(String) get inputName => _name.sink.add;
  Function(String) get inputPace => _pace.sink.add;

  AddAthleteBloc() {
    init();
  }

  submit() => _appBloc.addAthlete(Athlete(latestName!, latestPace!, id));

  init() {
    _athleteEditSubscription = _appBloc.athleteEdit.listen((athlete) {
      _initial.add({
        "name": athlete.name,
        "pace":
            "${athlete.pace.inMinutes}:${athlete.pace.inSeconds.remainder(60)}",
      });
      id = athlete.id;
    });
  }

  dispose() {
    _name.close();
    _pace.close();
    _initial.close();
    _athleteEditSubscription.cancel();
  }
}
