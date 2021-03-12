import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:pacemap/data/services/database.dart';
import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/state/appBloc.dart';
import 'package:rxdart/rxdart.dart';

class ListBloc {
  final _appBloc = GetIt.I<AppBloc>();
  final _db = GetIt.I<DatabaseHandler>();

  final _tracks = BehaviorSubject<List<GpsTrack>>();

  Stream<List<GpsTrack>> get tracks => _tracks.stream;

  late StreamSubscription tracksChangedSubscription;

  ListBloc() {
    init();
  }

  selectTrack(int index) async {
    if (_tracks.value != null) {
      final track = _tracks.value![index];
      _appBloc.selectTrack(track);
    }
  }

  updateTracks() async {
    final tracks = await _db.getTracks();
    _tracks.add(tracks);
  }

  init() {
    updateTracks();
    tracksChangedSubscription = _appBloc.tracksChanged.listen((_) {
      updateTracks();
    });
  }

  dispose() {
    _tracks.close();
    tracksChangedSubscription.cancel();
  }
}
