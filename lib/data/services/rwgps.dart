import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:pacemap/data/services/gps.dart';

class RWGPSClient {
  static const apiKey = "testkey1"; //public test key
  static const apiVersion = 2;
  static const baseUrl = "https://ridewithgps.com";

  final _client = Dio();

  List<GpsTrack> _parseTracks(Map<String, dynamic> body) {
    final list = <GpsTrack>[];
    for (final Map m in body["results"] ?? []) {
      final type = m["type"] == "trip" ? TrackType.trip : TrackType.route;
      Map details = type == TrackType.trip ? m["trip"] : m["route"];
      final id = details["id"];
      if (id == null) continue;
      final name = details["name"] ?? "unnamed track";
      final distance = ((details["distance"] ?? 0) / 1000).round();
      final url = (details["highlighted_photo_id"] ?? 0) != 0
          ? "$baseUrl/photos/${details["highlighted_photo_id"]}/sq_thumb.jpg"
          : null;
      list.add(GpsTrack(name, url, null, id, distance, type));
    }
    return list;
  }

  Future<List<GpsTrack>> searchTracks(String keyword) async {
    final options = {
      "search": {
        "keywords": "$keyword",
        "length-min": "1",
        "limit": "40",
      },
      "apikey": "$apiKey",
      "version": "$apiVersion",
    };
    final response = await _client.post(
      "$baseUrl/find/search.json",
      data: options,
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return _parseTracks(response.data);
    }
    return [];
  }

  Future getGpx(int id, TrackType type) async {
    final response = await _client.get(
        "$baseUrl/${type == TrackType.trip ? "trips" : "routes"}/$id.json");
    final list = <LatLng>[];
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      for (final Map m in response.data["track_points"] ?? []) {
        if (m.containsKey("x") && m.containsKey("y")) {
          list.add(LatLng(m["y"]!.toDouble(), m["x"]!.toDouble()));
        }
      }
      return list;
    }
    return [];
  }

  void close() {
    _client.close();
  }
}
