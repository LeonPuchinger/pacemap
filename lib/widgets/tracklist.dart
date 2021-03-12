import 'package:flutter/material.dart';
import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/state/list_bloc.dart';
import 'package:pacemap/widgets/trackentry.dart';

class Tracklist extends StatefulWidget {
  @override
  _TracklistState createState() => _TracklistState();
}

class _TracklistState extends State<Tracklist> {
  final _bloc = ListBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PaceMap"),
      ),
      body: SafeArea(
        child: StreamBuilder<List<GpsTrack>>(
          stream: _bloc.tracks,
          initialData: [],
          builder: (_, tracksSnapshot) {
            return ListView.builder(
              itemBuilder: (_, index) {
                final track = tracksSnapshot.data![index];
                return TrackEntry(
                  name: track.name,
                  distance: "${track.distance}",
                  url: track.thumbnailUrl,
                  onPressed: () => _bloc.selectTrack(index),
                );
              },
              itemCount: tracksSnapshot.data?.length,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Track"),
        icon: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, "list/add"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
