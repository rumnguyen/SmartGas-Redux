import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:intl/intl.dart';

const String formatDateConst = "dd/MM/yyyy";
const String formatTimeConst = "HH:mm";
const String formatTimeDateConst = "HH:mm dd/MM/yyyy";
const String formatTimeDateBreakLineConst = "HH:mm\ndd/MM";
const String formatDateNoYearConst = "dd/MM";
const String formatTimeDateNoYearConst = "HH:mm dd/MM";
const String formatDateTextConst = "dd MMM, yy";
const String formatDateTimeLongConst = "EEE, dd MMM yyyy";
const String formatMonthOnlyConst = "MMM";
const String formatDateTimeString = "yyyy-MM-ddTHH:mm:ss";
//2022-07-23T14:26:37.720679Z

String formatDateTime(
  DateTime? dateTime, {
  String formatDisplay = formatDateConst,
}) {
  if (dateTime == null || dateTime.millisecondsSinceEpoch == 0) {
    return "";
  }
  return DateFormat(formatDisplay).format(dateTime).toString();
}

DateTime? convertString2DateTime(
  String? src, {
  String formatConvert = formatTimeDateConst,
  bool isUtc = false,
}) {
  if (checkStringNullOrEmpty(src)) return null;
  try {
    return DateFormat(formatConvert).parse(src!, isUtc);
  } on Exception catch (e) {
    print("Error: ${e.toString()}");
    return null;
  }
}

int dtToUnix(DateTime? dt) {
  if (dt == null) return 0;
  return dt.millisecondsSinceEpoch ~/ 1000;
}

DateTime? unixToDateTime(int? unix) {
  if (unix == null || unix <= 0) {
    return null;
  }

  return DateTime.fromMillisecondsSinceEpoch(unix * 1000);
}

String formatTime(int hour, int minute) {
  return "${"$hour".padLeft(2, '0')}:${"$minute".padLeft(2, '0')}";
}

String getTimeStringBySecond(int second) {
  if (second == -1) return "[...]";
  String minuteString = GlobalManager.strings.minute!;
  if (second <= 60) return "<1 " + minuteString;
  return "${second ~/ 60} $minuteString";
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime? targetDate) {
    if (targetDate == null) return false;
    return (year == targetDate.year &&
        month == targetDate.month &&
        day == targetDate.day);
  }
}
