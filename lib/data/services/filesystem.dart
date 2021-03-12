import 'dart:io';

import 'package:latlng/latlng.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> _getGpxPath(int id) async {
  return join((await getApplicationDocumentsDirectory()).path, "$id.cgpx");
}

Future writeGPX(List<LatLng> gpx, int id) async {
  final path = await _getGpxPath(id);
  final file = File(path);
  final buffer = StringBuffer();
  for (final coord in gpx) {
    buffer.writeln("${coord.latitude};${coord.longitude}");
  }
  await file.writeAsString(buffer.toString());
}
