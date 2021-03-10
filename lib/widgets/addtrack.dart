import 'package:flutter/material.dart';
import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/state/add_bloc.dart';
import 'package:pacemap/widgets/trackentry.dart';
import 'package:rxdart/rxdart.dart';

class AddTrack extends StatefulWidget {
  @override
  _AddTrackState createState() => _AddTrackState();
}

class _AddTrackState extends State<AddTrack> {
  final _bloc = AddBloc();
  final _showSearch = BehaviorSubject<bool>.seeded(false);

  @override
  void dispose() {
    _bloc.dispose();
    _showSearch.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<bool>(
          stream: _showSearch.stream,
          initialData: false,
          builder: (_, showSearchSnapshot) {
            if (showSearchSnapshot.data!) {
              return TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search Gps-Tracks",
                  border: InputBorder.none,
                ),
                onChanged: _bloc.inputSearch,
              );
            } else {
              return Text("Add Gps-Track");
            }
          },
        ),
        actions: [
          StreamBuilder<bool>(
              stream: _showSearch.stream,
              initialData: false,
              builder: (_, showSearchSnapshot) {
                return IconButton(
                  icon: showSearchSnapshot.data!
                      ? Icon(Icons.close)
                      : Icon(Icons.search),
                  onPressed: () => _showSearch.add(!(showSearchSnapshot.data!)),
                );
              }),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<GpsTrack>>(
          stream: _bloc.tracks,
          initialData: [],
          builder: (_, searchSnapshot) {
            return ListView.builder(
              itemBuilder: (_, index) {
                final track = searchSnapshot.data![index];
                return TrackEntry(
                  name: track.name,
                  distance: "${track.distance}",
                  url: track.thumbnailUrl,
                  onPressed: () {},
                );
              },
              itemCount: searchSnapshot.data?.length,
            );
          },
        ),
      ),
    );
  }
}
