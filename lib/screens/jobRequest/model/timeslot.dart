import 'dart:math';

enum Timeslots { Morning, Noon, Night }

class Timeslot {
  final Timeslots slot;
  final String name; // (Morning , Noon , Night)
  final String nameAr; // (صباح - مساء - ليل)
  final String time; // Key for checking
  final String timeString; // For display
  final String timeStringAr; // For display

  bool isAvailable(DateTime date) {
    return !inRange(date, time, slot);
    // return false;
  }

  Timeslot({required this.slot, required this.name, required this.nameAr, required this.time, required this.timeString, required this.timeStringAr}); // (12am - 6pm)
}

bool inRange(DateTime dateTime, String timeRange, Timeslots slot) {
  // Get current date
  DateTime now = DateTime.now();

  // Check if the provided datetime is today
  if (dateTime.year != now.year || dateTime.month != now.month || dateTime.day != now.day) {
    return false;
  }

  // Extract start and end times from the timeRange string
  List<String> times = timeRange.split(' - ');
  String startTime = times[0];
  String endTime = times[1];

  int endTimeHour = convertTo24HourFormat(endTime);
  print('====================================');
  print(slot.name);
  print("now.hour : ${now.hour}");
  print("endTimeHour : ${endTimeHour}");

  if (endTimeHour <= (now.hour)) {
    return true;
  } else {
    return false;
  }

  // // Parse time strings into DateTime objects
  // DateTime start = _parseTime(startTime);
  // DateTime end = _parseTime(endTime);

  // // Adjust end time if it's before start time (indicating it ends on the next day)
  // if (end.isBefore(start)) {
  //   end = end.add(Duration(days: 1));
  // }

  // // Check if the current time is within the time range
  // DateTime currentTime = DateTime.now();
  // DateTime currentDateTime = DateTime(now.year, now.month, now.day, currentTime.hour, currentTime.minute);

  // return currentDateTime.isAfter(start) && currentDateTime.isBefore(end);
}

// DateTime _parseTime(String time) {
//   // Adjust the time format to include seconds
//   String formattedTime = time.replaceAllMapped(RegExp(r'(\d{1,2}:\d{2}) (AM|PM)'), (match) {
//     String hourMinute = match.group(1)!;
//     String amPm = match.group(2)!;
//     return '$hourMinute:00 $amPm';
//   });
//   return DateTime.parse("1970-01-01 $formattedTime");
// }

int convertTo24HourFormat(String time) {
  int res = 0;
  if (time.contains('am')) {
    res = int.parse(time.replaceAll('am', '').replaceAll(' ', ''));
  } else if (time.contains('pm')) {
    res = int.parse(time.replaceAll('pm', '').replaceAll(' ', '')) + 12;
  } else {
    // res = ;
  }

  return res;
}
