import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/services/map.dart';
import 'package:rxdart/subjects.dart';

class AppBloc {
  final _tracksChanged = BehaviorSubject<void>();
  final _selectedTrack = BehaviorSubject<GpsTrack>();
  final _athleteAdded = PublishSubject<Athlete>();

  Stream<void> get tracksChanged => _tracksChanged.stream;
  Stream<GpsTrack> get selectedTrack => _selectedTrack.stream;
  Stream<Athlete> get athleteAdded => _athleteAdded.stream;

  Function() get setTracksChanged => () => _tracksChanged.add(null);
  Function(GpsTrack) get selectTrack => _selectedTrack.add;
  Function(Athlete) get addAthlete => _athleteAdded.add;

  dispose() {
    _tracksChanged.close();
    _selectedTrack.close();
    _athleteAdded.close();
  }
}
