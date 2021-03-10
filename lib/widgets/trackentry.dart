import 'package:flutter/material.dart';

class TrackEntry extends StatefulWidget {
  final String name, distance;
  final String? url;
  final Function()? onPressed;

  TrackEntry({
    required this.name,
    required this.distance,
    this.url,
    this.onPressed,
  });

  @override
  _TrackEntryState createState() => _TrackEntryState();
}

class _TrackEntryState extends State<TrackEntry> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AspectRatio(
        aspectRatio: 1,
        child: widget.url != null
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(widget.url!, fit: BoxFit.cover),
              )
            : Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Icon(Icons.broken_image),
              ),
      ),
      title: Text(widget.name),
      subtitle: Text("${widget.distance} km"),
      onTap: widget.onPressed,
    );
  }
}
