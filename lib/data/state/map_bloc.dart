import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:latlng/latlng.dart';
import 'package:pacemap/data/services/filesystem.dart';
import 'package:pacemap/data/state/appBloc.dart';
import 'package:rxdart/rxdart.dart';

class MapBloc {
  final _appBloc = GetIt.I<AppBloc>();

  final _gpx = BehaviorSubject<List<LatLng>>();

  Stream<List<LatLng>> get gpx => _gpx.stream;

  late StreamSubscription selectedTrackSubscription;

  MapBloc() {
    init();
  }

  init() {
    selectedTrackSubscription = _appBloc.selectedTrack.listen((track) async {
      final gpx = await readGpx(track.id);
      _gpx.add(gpx);
    });
  }

  dispose() {
    _gpx.close();
    selectedTrackSubscription.cancel();
  }
}
