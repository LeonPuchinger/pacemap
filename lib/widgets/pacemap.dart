import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlng/latlng.dart' as latlng;
import 'package:pacemap/data/services/map.dart';
import 'package:pacemap/data/state/map_bloc.dart';
import 'package:pacemap/widgets/mapstyles.dart';

class PaceMap extends StatefulWidget {
  @override
  _PaceMapState createState() => _PaceMapState();
}

class _PaceMapState extends State<PaceMap> {
  final _bloc = MapBloc();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    late StreamSubscription sub;
    sub = _bloc.initialTime.listen(
      (time) {
        _timeController.text = time.toString();
        sub.cancel();
      },
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  showAddDialog(context) async {
    final bloc = AddAthleteBloc();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(20, 24, 20, 10),
          title: Text("Add athlete to track"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(Icons.person),
                  title: StreamBuilder<String>(
                    stream: bloc.name,
                    builder: (_, nameSnapshot) {
                      return TextField(
                        onChanged: bloc.inputName,
                        decoration: InputDecoration(
                          hintText: "Name",
                          errorText: nameSnapshot.error?.toString(),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(Icons.person),
                  title: StreamBuilder<Duration>(
                    stream: bloc.pace,
                    builder: (_, paceSnapshot) {
                      return TextField(
                        onChanged: bloc.inputPace,
                        decoration: InputDecoration(
                          hintText: "Pace",
                          errorText: paceSnapshot.error?.toString(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            StreamBuilder<bool>(
              stream: bloc.validated,
              builder: (context, validatedSnapshot) {
                return TextButton(
                  child: Text("Add"),
                  onPressed: validatedSnapshot.hasData
                      ? () {
                          bloc.submit();
                          Navigator.of(context).pop();
                        }
                      : null,
                );
              },
            ),
          ],
        );
      },
    );
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
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
            ListTile(
              leading: Icon(Icons.timer),
              title: StreamBuilder<DateTime>(
                  stream: _bloc.startTime,
                  builder: (context, snapshot) {
                    return TextField(
                      onChanged: _bloc.setStartTime,
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: "race start time",
                        errorText: snapshot.error as String?,
                      ),
                    );
                  }),
            ),
            StreamBuilder<List<Athlete>>(
              stream: _bloc.athletes,
              initialData: [],
              builder: (_, athletesSnapshot) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    final athlete = athletesSnapshot.data![index];
                    return ListTile(
                      leading: Icon(Icons.directions_run),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(athlete.name),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: athletesSnapshot.data!.length,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        tooltip: "Add athlete to track",
        onPressed: () => showAddDialog(context),
      ),
    );
  }
}
