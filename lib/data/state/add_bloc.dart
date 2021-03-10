import 'dart:async';

import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/services/rwgps.dart';
import 'package:rxdart/rxdart.dart';

class AddBloc {
  final _client = RWGPSClient();

  final _search = BehaviorSubject<String>();
  final _tracks = BehaviorSubject<List<GpsTrack>>();
  final _loading = BehaviorSubject<bool>.seeded(false);
  final _download = BehaviorSubject<bool>.seeded(false);

  Stream<String> get search =>
      _search.stream.debounceTime(Duration(milliseconds: 500));
  Stream<List<GpsTrack>> get tracks => _tracks.stream;
  Stream<bool> get loading => _loading.stream;
  Stream<bool> get download => _download.stream;

  Function(String) get inputSearch => _search.add;

  AddBloc() {
    init();
  }

  selectTrack(int index) async {
    if (_tracks.value != null) {
      _download.add(true);
      final track = _tracks.value![index];
      final gpx = await _client.getGpx(track.id, track.type);
      _download.add(false);
    }
  }

  init() {
    search.listen((keyword) async {
      _loading.add(true);
      final tracks = await _client.searchTracks(keyword);
      _tracks.add(tracks);
      _loading.add(false);
    });
  }

  dispose() {
    _search.close();
    _tracks.close();
    _loading.close();
    _download.close();
    _client.close();
  }
}
