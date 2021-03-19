import 'dart:math';

import 'package:latlong2/latlong.dart';

class Athlete {
  final String name;
  final Duration pace;
  int? id;

  Athlete(this.name, this.pace, [this.id]);
}

class Tracker {
  final List<LatLng> _track;

  Tracker(this._track);

  trackAthlete(Athlete athlete, LatLng location, Duration raceTime) {
    final totalDistance = _pathDistance(_track.length - 1);
    final waypointSpectator = _nearest(location);
    final posSpectator = _track[waypointSpectator];
    final distStartSpectator = _pathDistance(waypointSpectator);
    final distStartAthlete =
        _precision(raceTime.inMinutes / athlete.pace.inMinutes, 3);
    final posAthlete = _distanceToPosition(distStartAthlete);
    final distAthleteFinish = _precision(totalDistance - distStartAthlete, 3);
    final distAthleteSpectator =
        _precision(distStartSpectator - distStartAthlete, 3);
    final timeAthleteFinish = Duration(
        milliseconds:
            (distAthleteFinish * athlete.pace.inMilliseconds).round());
    final timeAthleteSpectator = Duration(
        milliseconds:
            (distAthleteSpectator * athlete.pace.inMilliseconds).round());
    return {
      "posSpectator": posSpectator,
      "posAthlete": posAthlete,
      "distStartAthlete": distStartAthlete,
      "distStartSpectator": distStartSpectator,
      "distAthleteFinish": distAthleteFinish,
      "distAthleteSpectator": distAthleteSpectator,
      "timeAthleteFinish": timeAthleteFinish,
      "timeAthleteSpectator": timeAthleteSpectator,
    };
  }

  _distanceToPosition(double distance) {
    distance = distance * 100000;
    var d = 0.0;
    int i = 1;
    while (d <= distance) {
      final add = _distance(_track[i], _track[i - 1], l: LengthUnit.Centimeter);
      d += add;
      i++;
    }
    return _track[i];
  }

  _nearest(LatLng location) {
    final nearest = {
      "index": 0,
      "distance": _distance(_track[0], location, l: LengthUnit.Meter)
    };
    for (var i = 1; i < _track.length; i++) {
      final d = _distance(_track[i], location, l: LengthUnit.Meter);
      if (d <= nearest["distance"]) {
        nearest["index"] = i;
        nearest["distance"] = d;
      }
    }
    return nearest["index"];
  }

  _pathDistance(int index,
      {LengthUnit l = LengthUnit.Kilometer, smooth = true}) {
    final path = Path.from(_track.sublist(0, index));
    if (smooth) {
      final smoothPath = path.equalize(8, smoothPath: true);
      return _precision(smoothPath.distance / 1000, 3);
    }
    return _precision(path.distance / 1000, 3);
  }

  _distance(LatLng a, LatLng b, {LengthUnit l = LengthUnit.Kilometer}) {
    final d = Distance();
    return d.as(l, a, b);
  }

  double _precision(double val, double decimals) {
    final mod = pow(10, decimals);
    return ((val * mod).round().toDouble() / mod);
  }
}
