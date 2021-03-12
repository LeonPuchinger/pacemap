import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:pacemap/data/state/map_bloc.dart';

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
        child: StreamBuilder<List<LatLng>>(
          stream: _bloc.gpx,
          initialData: [],
          builder: (_, gpxSnapshot) {
            return ListView.builder(
              itemBuilder: (_, int index) {
                final c = gpxSnapshot.data![index];
                return Text("${c.latitude} ${c.longitude}");
              },
              itemCount: gpxSnapshot.data!.length,
            );
          },
        ),
      ),
    );
  }
}
