import 'package:rxdart/subjects.dart';

class AppBloc {
  final _tracksChanged = BehaviorSubject<void>();

  Stream<void> get tracksChanged => _tracksChanged.stream;

  Function() get setTracksChanged => () => _tracksChanged.add(null);

  dispose() {
    _tracksChanged.close();
  }
}
