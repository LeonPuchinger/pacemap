import 'dart:async';

import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/services/rwgps.dart';
import 'package:rxdart/rxdart.dart';

class AddBloc {
  final _client = RWGPSClient();

  final _search = BehaviorSubject<String>();

  Stream<List<GpsTrack>> get tracks =>
      _search.debounceTime(Duration(milliseconds: 500)).transform(
          StreamTransformer.fromHandlers(handleData: (keyword, sink) async {
        final result = await _client.searchRoutes(keyword);
        sink.add(result);
      }));

  Function(String) get inputSearch => _search.add;

  dispose() {
    _search.close();
    _client.close();
  }
}
