import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:pacemap/data/services/map.dart';
import 'package:pacemap/data/state/map_bloc.dart';
import 'package:pacemap/util/dual_streambuilder.dart';
import 'package:pacemap/util/formatter.dart';
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
    final _nameController = TextEditingController();
    final _paceController = TextEditingController();
    bloc.initial.listen((initial) {
      final name = initial["name"] ?? "";
      final pace = initial["pace"] ?? "";
      _nameController.text = name;
      _paceController.text = pace;
      bloc.inputName(name);
      bloc.inputPace(pace);
    });
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
                        controller: _nameController,
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
                        controller: _paceController,
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
              child: StreamBuilder<List<latlong.LatLng>>(
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
            DualStreamBuilder<List<Athlete>, List<Map<String, dynamic>>>(
              streamA: _bloc.athletes,
              streamB: _bloc.trackData,
              initialDataA: [],
              builder: (_, athletesSnapshot, trackDataSnapshot) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    final athlete = athletesSnapshot.data![index];
                    final trackData = trackDataSnapshot.data?[index];
                    return AthleteTrack(
                      athlete: athlete,
                      trackData: trackData,
                      onEditPressed: () {
                        _bloc.editAthlete(index);
                        showAddDialog(context);
                      },
                      onRemovePressed: () => _bloc.deleteAthlete(index),
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

class AthleteTrack extends StatelessWidget {
  final Athlete athlete;
  final Map<String, dynamic>? trackData;
  final Function() onEditPressed, onRemovePressed;

  AthleteTrack({
    required this.athlete,
    required this.trackData,
    required this.onEditPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.directions_run),
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: Text(athlete.name),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEditPressed,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onRemovePressed,
                ),
              ],
            ),
          ),
          Text(
            "pace: ${formatDuration(athlete.pace)}",
          ),
          Text(
            "athlete currently at: ${trackData?["distStartAthlete"] ?? "--"} km",
          ),
          Text(
            "athlete's distance to finish: ${trackData?["distAthleteFinish"] ?? "--"} km",
          ),
          Text(
            "spectator currently at: ${trackData?["distStartSpectator"] ?? "--"} km",
          ),
          Text(
            "distance between athlete and spectator: ${trackData?["distAthleteSpectator"] ?? "--"} km",
          ),
          Text(
            "athlete's time to finish: ${trackData?["timeAthleteFinish"] != null ? formatDuration(trackData!["timeAthleteFinish"]) : "--"} h",
          ),
          Text(
            "athlete's time to spectator: ${trackData?["timeAthleteSpectator"] != null ? formatDuration(trackData!["timeAthleteSpectator"]) : "--"} h",
          ),
        ],
      ),
    );
  }
}
