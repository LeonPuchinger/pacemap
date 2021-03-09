enum TrackType { route, trip }

class GpsTrack {
  final String name;
  final String? thumbnailUrl;
  final int id, distance;
  final TrackType type;

  GpsTrack(this.name, this.thumbnailUrl, this.id, this.distance, this.type);
}
