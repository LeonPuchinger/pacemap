import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/services/map.dart';
import 'package:pacemap/util/oblivious_subject.dart';
import 'package:rxdart/rxdart.dart';

class AppBloc {
  final _tracksChanged = BehaviorSubject<void>();
  final _selectedTrack = BehaviorSubject<GpsTrack>();
  final _athleteAdded = PublishSubject<Athlete>();
  final _athleteEdit = BehaviorSubject<Athlete?>();

  Stream<void> get tracksChanged => _tracksChanged.stream;
  Stream<GpsTrack> get selectedTrack => _selectedTrack.stream;
  Stream<Athlete> get athleteAdded => _athleteAdded.stream;
  Stream<Athlete> get athleteEdit => _athleteEdit.obliviousStream;

  Function() get setTracksChanged => () => _tracksChanged.add(null);
  Function(GpsTrack) get selectTrack => _selectedTrack.add;
  Function(Athlete) get addAthlete => _athleteAdded.add;
  Function(Athlete) get editAthlete => _athleteEdit.add;

  dispose() {
    _tracksChanged.close();
    _selectedTrack.close();
    _athleteAdded.close();
    _athleteEdit.close();
  }
}
