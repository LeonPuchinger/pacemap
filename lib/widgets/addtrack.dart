import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pacemap/data/services/gps.dart';
import 'package:pacemap/data/state/add_bloc.dart';
import 'package:pacemap/util/dual_streambuilder.dart';
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
        child: Stack(
          children: [
            DualStreamBuilder<List<GpsTrack>, bool>(
              streamA: _bloc.tracks,
              streamB: _bloc.loading,
              initialDataA: [],
              initialDataB: false,
              builder: (_, searchSnapshot, loadingSnapshot) {
                if (loadingSnapshot.data ?? false) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemBuilder: (_, index) {
                    final track = searchSnapshot.data![index];
                    return TrackEntry(
                      name: track.name,
                      distance: "${track.distance}",
                      url: track.thumbnailUrl,
                      onPressed: () => _bloc.selectTrack(index),
                    );
                  },
                  itemCount: searchSnapshot.data?.length,
                );
              },
            ),
            StreamBuilder<bool>(
              stream: _bloc.download,
              initialData: false,
              builder: (_, downloadSnapshot) {
                if (downloadSnapshot.data ?? false) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      children: [
                        LinearProgressIndicator(),
                        Expanded(
                          child: Center(
                            child: Text("Downloading GPS-Track..."),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
