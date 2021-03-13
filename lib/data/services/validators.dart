import 'dart:async';

mixin TimeValidator {
  final timeValidator = StreamTransformer<String, DateTime>.fromHandlers(
      handleData: (time, sink) {
    var dateTime = DateTime.tryParse(time);
    if (dateTime != null) {
      sink.add(dateTime);
      return;
    }
    final simpleTime = r"([01]\d|2[0-3]):([0-5]\d)";
    final rSimpleTime = RegExp(simpleTime);
    if (rSimpleTime.hasMatch(time)) {
      final match = rSimpleTime.firstMatch(time)!;
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      int day, month, year;
      final simpleDateTime =
          r"(3[01]|[12][0-9]|0?[1-9])\.(1[012]|0?[1-9])\.([2-9][0-9]{3})";
      final rSimpleDateTime = RegExp(simpleDateTime);
      if (rSimpleDateTime.hasMatch(time)) {
        final match = rSimpleDateTime.firstMatch(time)!;
        day = int.parse(match.group(1)!);
        month = int.parse(match.group(2)!);
        year = int.parse(match.group(3)!);
      } else {
        final today = DateTime.now();
        day = today.day;
        month = today.month;
        year = today.year;
      }
      dateTime = DateTime(year, month, day, hour, minute);
      sink.add(dateTime);
      return;
    }
    sink.addError("Invalid time format");
  });

  final timeFormatter = StreamTransformer<DateTime, String>.fromHandlers(
      handleData: (time, sink) {
    sink.add(
      "${time.hour < 10 ? "0${time.hour}" : time.hour}:${time.minute < 10 ? "0${time.minute}" : time.minute}",
    );
  });
}

mixin AthleteValidator {
  final paceValidator = StreamTransformer<String, Duration>.fromHandlers(
      handleData: (pace, sink) {
    final p = r"^([0-9]?[0-9]):([0-5][0-9])$";
    final regex = new RegExp(p);
    if (regex.hasMatch(pace)) {
      final match = regex.firstMatch(pace);
      sink.add(Duration(
        minutes: int.parse(match!.group(1)!),
        seconds: int.parse(match.group(2)!),
      ));
    } else {
      sink.addError("Pace does not have a valid format");
    }
  });

  final nameValidator =
      StreamTransformer<String, String>.fromHandlers(handleData: (name, sink) {
    if (name.length >= 3) {
      sink.add(name);
    } else {
      sink.addError("Name has to be at least 3 characters");
    }
  });
}
