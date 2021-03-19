String formatDuration(Duration d) {
  if (d.inHours > 0) {
    return "${d.inHours}:${d.inMinutes.remainder(60)}:${d.inSeconds.remainder(60)}";
  }
  return "${d.inMinutes}:${d.inSeconds.remainder(60)}";
}
