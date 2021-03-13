enum TrackType { route, trip }

class GpsTrack {
  final String name;
  final String? thumbnailUrl;
  DateTime? startTime;
  final int id, distance;
  final TrackType type;

  GpsTrack(
    this.name,
    this.thumbnailUrl,
    this.startTime,
    this.id,
    this.distance,
    this.type,
  );
}
