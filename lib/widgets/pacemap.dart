import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlng/latlng.dart' as latlng;
import 'package:pacemap/data/state/map_bloc.dart';
import 'package:pacemap/widgets/mapstyles.dart';

class PaceMap extends StatefulWidget {
  @override
  _PaceMapState createState() => _PaceMapState();
}

class _PaceMapState extends State<PaceMap> {
  final _bloc = MapBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SafeArea(
        child: StreamBuilder<List<latlng.LatLng>>(
          stream: _bloc.gpx,
          initialData: [],
          builder: (_, gpxSnapshot) {
            return GoogleMap(
              polylines: Set.from([
                Polyline(
                  points: gpxSnapshot.data!
                      .map((c) => LatLng(c.latitude, c.longitude))
                      .toList(),
                  width: 4,
                  polylineId: PolylineId("superUniqueId"),
                  color: Colors.red,
                ),
              ]),
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(50, 10),
                zoom: 0,
              ),
              onMapCreated: (controller) {
                controller.setMapStyle(dark);
              },
            );
          },
        ),
      ),
    );
  }
}
