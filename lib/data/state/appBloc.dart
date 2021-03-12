import 'package:pacemap/data/services/gps.dart';
import 'package:rxdart/subjects.dart';

class AppBloc {
  final _tracksChanged = BehaviorSubject<void>();
  final _selectedTrack = BehaviorSubject<GpsTrack>();

  Stream<void> get tracksChanged => _tracksChanged.stream;
  Stream<GpsTrack> get selectedTrack => _selectedTrack.stream;

  Function() get setTracksChanged => () => _tracksChanged.add(null);
  Function(GpsTrack) get selectTrack => _selectedTrack.add;

  dispose() {
    _tracksChanged.close();
    _selectedTrack.close();
  }
}
