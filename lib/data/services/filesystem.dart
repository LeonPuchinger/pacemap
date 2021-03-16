import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:pacemap/data/services/parser.dart';
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

Future<List<LatLng>> readGpx(int id) async {
  final path = await _getGpxPath(id);
  final file = File(path);
  final gpx = await file.readAsLines();
  final list = <LatLng>[];
  for (final coord in gpx) {
    final result = cGPX.parse(coord);
    if (result.isSuccess) {
      list.add(LatLng(result.value[0], result.value[1]));
    }
  }
  return list;
}
