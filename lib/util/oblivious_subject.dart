import 'package:rxdart/rxdart.dart';

extension Oblivious_Subject<T> on BehaviorSubject<T?> {
  /// discards last value of BehaviorSubject once a subscriber has consumed it
  Stream<T> get obliviousStream => this
      .where((value) => value != null)
      .doOnData((_) => this.add(null))
      .cast<T>();
}
