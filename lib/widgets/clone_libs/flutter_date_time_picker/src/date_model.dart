import 'dart:math';

import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/widgets/clone_libs/flutter_date_time_picker/src/date_format.dart';
import 'package:anpha_petrol_smartgas/widgets/clone_libs/flutter_date_time_picker/src/i18n_model.dart';

import 'datetime_util.dart';

//interface for picker data model
abstract class BasePickerModel {
  //a getter method for left column data, return null to end list
  String leftStringAtIndex(int index);

  //a getter method for middle column data, return null to end list
  String middleStringAtIndex(int index);

  //a getter method for right column data, return null to end list
  String rightStringAtIndex(int index);

  //set selected left index
  void setLeftIndex(int index);

  //set selected middle index
  void setMiddleIndex(int index);

  //set selected right index
  void setRightIndex(int index);

  //return current left index
  int currentLeftIndex();

  //return current middle index
  int currentMiddleIndex();

  //return current right index
  int currentRightIndex();

  //return final time
  DateTime? finalTime();

  //return final list time
  List<DateTime>? finalListTime();

  //return left divider string
  String leftDivider();

  //return right divider string
  String rightDivider();

  //layout proportions for 3 columns
  List<int> layoutProportions();
}

//a base class for picker data model
class CommonPickerModel extends BasePickerModel {
  List<String> leftList = [];
  List<String> middleList = [];
  List<String> rightList = [];
  late DateTime currentTime;
  int _currentLeftIndex = 0;
  int _currentMiddleIndex = 0;
  int _currentRightIndex = 0;

  LocaleType locale;

  CommonPickerModel({locale}) : this.locale = locale ?? LocaleType.en;

  @override
  String leftStringAtIndex(int index) {
    return "";
  }

  @override
  String middleStringAtIndex(int index) {
    return "";
  }

  @override
  String rightStringAtIndex(int index) {
    return "";
  }

  @override
  int currentLeftIndex() {
    return _currentLeftIndex;
  }

  @override
  int currentMiddleIndex() {
    return _currentMiddleIndex;
  }

  @override
  int currentRightIndex() {
    return _currentRightIndex;
  }

  @override
  void setLeftIndex(int index) {
    _currentLeftIndex = index;
  }

  @override
  void setMiddleIndex(int index) {
    _currentMiddleIndex = index;
  }

  @override
  void setRightIndex(int index) {
    _currentRightIndex = index;
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime? finalTime() {
    return null;
  }

  @override
  List<DateTime>? finalListTime() {
    return null;
  }
}

//a date picker model
class DatePickerModel extends CommonPickerModel {
  DateTime? maxTime;
  DateTime? minTime;
  bool showDaysColumns;
  bool? limitChildren;
  int? childCount;

  DatePickerModel({
    DateTime? currentTime,
    DateTime? maxTime,
    DateTime? minTime,
    LocaleType? locale,
    this.limitChildren,
    this.showDaysColumns = true,
    int? childCountParam,
  }) : super(locale: locale) {
    if (childCountParam != null) {
      childCount = childCountParam;
    } else if (limitChildren == true && minTime != null && maxTime != null) {
      childCount = maxTime.difference(minTime).inDays + 1;
    }
    this.maxTime = maxTime ?? DateTime(2049, 12, 31);
    this.minTime = minTime ?? DateTime(1970, 1, 1);

    currentTime = currentTime ?? DateTime.now();
    if (currentTime.compareTo(this.maxTime!) > 0) {
      currentTime = this.maxTime;
    } else if (currentTime.compareTo(this.minTime!) < 0) {
      currentTime = this.minTime;
    }
    this.currentTime = currentTime!;

    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentLeftIndex = this.currentTime.day - minDay;
    _currentMiddleIndex = this.currentTime.month - minMonth;
    _currentRightIndex = this.currentTime.year - this.minTime!.year;
  }

  void _fillRightLists() {
    rightList = List.generate(maxTime!.year - minTime!.year + 1, (int index) {
      // print('LEFT LIST... ${minTime.year + index}${_localeYear()}');
      return '${minTime!.year + index}${_localeYear()}';
    });
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year == maxTime!.year ? maxTime!.month : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime!.year ? minTime!.month : 1;
  }

  int _maxDayOfCurrentMonth() {
    int dayCount = calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime!.year &&
            currentTime.month == maxTime!.month
        ? maxTime!.day
        : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime!.year &&
            currentTime.month == minTime!.month
        ? minTime!.day
        : 1;
  }

  void _fillMiddleLists() {
    int minMonth = _minMonthOfCurrentYear();
    int maxMonth = _maxMonthOfCurrentYear();

    middleList = List.generate(maxMonth - minMonth + 1, (int index) {
      return _localeMonth(minMonth + index);
    });
  }

  void _fillLeftLists() {
    int maxDay = _maxDayOfCurrentMonth();
    int minDay = _minDayOfCurrentMonth();
    leftList = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}${_localeDay()}';
    });
  }

  @override
  void setLeftIndex(int index) {
    if (index < 0) return;
    super.setLeftIndex(index);
    int minDay = _minDayOfCurrentMonth();
    printDefault('setLeftIndex $index');
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            minDay + index,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            minDay + index,
          );
  }

  @override
  void setMiddleIndex(int index) {
    if (index < 0) return;
    super.setMiddleIndex(index);
    //adjust right
    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          )
        : DateTime(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          );
    //min/max check
    if (newTime.isAfter(maxTime!)) {
      currentTime = maxTime!;
    } else if (newTime.isBefore(minTime!)) {
      currentTime = minTime!;
    } else {
      currentTime = newTime;
    }

    _fillLeftLists();
    int minDay = _minDayOfCurrentMonth();
    _currentLeftIndex = currentTime.day - minDay;
  }

  @override
  void setRightIndex(int index) {
    if (index < 0) return;
    super.setRightIndex(index);

    //adjust middle
    int destYear = index + minTime!.year;
    int minMonth = _minMonthOfCurrentYear();
    DateTime newTime;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              calcDateCount(destYear, 2),
            )
          : DateTime(
              destYear,
              currentTime.month,
              calcDateCount(destYear, 2),
            );
    } else {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              currentTime.day,
            )
          : DateTime(
              destYear,
              currentTime.month,
              currentTime.day,
            );
    }
    //min/max check
    if (newTime.isAfter(maxTime!)) {
      currentTime = maxTime!;
    } else if (newTime.isBefore(minTime!)) {
      currentTime = minTime!;
    } else {
      currentTime = newTime;
    }

    _fillMiddleLists();
    _fillLeftLists();
    minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentMiddleIndex = currentTime.month - minMonth;
    _currentLeftIndex = currentTime.day - minDay;
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 0 && index < leftList.length) {
      return leftList[index];
    } else {
      return "";
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < middleList.length) {
      return middleList[index];
    } else {
      return "";
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 0 && index < rightList.length) {
      return rightList[index];
    } else {
      return "";
    }
  }

  String _localeYear() {
    return '';
  }

  String _localeMonth(int month) {
    Map<String, Object>? localeMap = i18nObjInLocale(locale);
    List monthStrings = (localeMap!['monthLong'] as List?) ?? [];
    return monthStrings[month - 1];
  }

  String _localeDay() {
    return '';
  }

  @override
  DateTime finalTime() {
    return currentTime;
  }

  @override
  List<int> layoutProportions() {
    if (showDaysColumns) {
      return [1, 1, 1];
    } else {
      return [0, 1, 1];
    }
  }
}

//a time picker model
class TimePickerModel extends CommonPickerModel {
  bool showSecondsColumn;

  TimePickerModel(
      {DateTime? currentTime,
      LocaleType? locale,
      this.showSecondsColumn = true})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();

    _currentLeftIndex = this.currentTime.hour;
    _currentMiddleIndex = this.currentTime.minute;
    _currentRightIndex = this.currentTime.second;
  }

  @override
  String leftStringAtIndex(int index) {
    return digits(index % 24, 2);
  }

  @override
  String middleStringAtIndex(int index) {
    return digits(index % 60, 2);
  }

  @override
  String rightStringAtIndex(int index) {
    return digits(index % 60, 2);
  }

  @override
  void setLeftIndex(int index) {
    _currentLeftIndex = index % 24;
  }

  @override
  void setMiddleIndex(int index) {
    _currentMiddleIndex = index % 60;
  }

  @override
  void setRightIndex(int index) {
    _currentRightIndex = index % 60;
  }

  @override
  String leftDivider() {
    return ":";
  }

  @override
  String rightDivider() {
    if (showSecondsColumn) {
      return ":";
    } else {
      return "";
    }
  }

  @override
  List<int> layoutProportions() {
    if (showSecondsColumn) {
      return [1, 1, 1];
    } else {
      return [1, 1, 0];
    }
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
            _currentLeftIndex, _currentMiddleIndex, _currentRightIndex)
        : DateTime(currentTime.year, currentTime.month, currentTime.day,
            _currentLeftIndex, _currentMiddleIndex, _currentRightIndex);
  }
}

//a time picker model
class Time12hPickerModel extends CommonPickerModel {
  Time12hPickerModel({DateTime? currentTime, LocaleType? locale})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();

    _currentLeftIndex = this.currentTime.hour % 12;
    _currentMiddleIndex = this.currentTime.minute;
    _currentRightIndex = this.currentTime.hour < 12 ? 0 : 1;
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 0 && index < 12) {
      if (index == 0) {
        return digits(12, 2);
      } else {
        return digits(index, 2);
      }
    } else {
      return "";
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return "";
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index == 0) {
      return i18nObjInLocale(locale)!["am"]?.toString() ?? "";
    } else if (index == 1) {
      return i18nObjInLocale(locale)!["pm"]?.toString() ?? "";
    } else {
      return "";
    }
  }

  @override
  String leftDivider() {
    return ":";
  }

  @override
  String rightDivider() {
    return ":";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime finalTime() {
    int hour = _currentLeftIndex + 12 * _currentRightIndex;
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
            hour, _currentMiddleIndex, 0)
        : DateTime(currentTime.year, currentTime.month, currentTime.day, hour,
            _currentMiddleIndex, 0);
  }
}

// a date&time picker model
class DateTimePickerModel extends CommonPickerModel {
  DateTime? maxTime;
  DateTime? minTime;

  DateTimePickerModel(
      {DateTime? currentTime,
      DateTime? maxTime,
      DateTime? minTime,
      LocaleType? locale})
      : super(locale: locale) {
    if (currentTime != null) {
      this.currentTime = currentTime;
      if (maxTime != null &&
          (currentTime.isBefore(maxTime) ||
              currentTime.isAtSameMomentAs(maxTime))) {
        this.maxTime = maxTime;
      }
      if (minTime != null &&
          (currentTime.isAfter(minTime) ||
              currentTime.isAtSameMomentAs(minTime))) {
        this.minTime = minTime;
      }
    } else {
      this.maxTime = maxTime;
      this.minTime = minTime;
      var now = DateTime.now();
      if (this.minTime != null && this.minTime!.isAfter(now)) {
        this.currentTime = this.minTime!;
      } else if (this.maxTime != null && this.maxTime!.isBefore(now)) {
        this.currentTime = this.maxTime!;
      } else {
        this.currentTime = now;
      }
    }

    if (this.minTime != null &&
        this.maxTime != null &&
        this.maxTime!.isBefore(this.minTime!)) {
      // invalid
      this.minTime = null;
      this.maxTime = null;
    }

    _currentLeftIndex = 0;
    _currentMiddleIndex = this.currentTime.hour;
    _currentRightIndex = this.currentTime.minute;
    if (this.minTime != null && isAtSameDay(this.minTime!, this.currentTime)) {
      _currentMiddleIndex = this.currentTime.hour - this.minTime!.hour;
      if (_currentMiddleIndex == 0) {
        _currentRightIndex = this.currentTime.minute - this.minTime!.minute;
      }
    }
  }

  bool isAtSameDay(DateTime? day1, DateTime? day2) {
    return day1 != null &&
        day2 != null &&
        day1.difference(day2).inDays == 0 &&
        day1.day == day2.day;
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);

    DateTime time = currentTime.add(Duration(days: index));
    if (isAtSameDay(minTime, time)) {
      var index = min(24 - minTime!.hour - 1, _currentMiddleIndex);
      setMiddleIndex(index);
    } else if (isAtSameDay(maxTime, time)) {
      var index = min(maxTime!.hour, _currentMiddleIndex);
      setMiddleIndex(index);
    }
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    index = index % 24;
    DateTime time = currentTime.add(Duration(days: _currentLeftIndex));
    if (isAtSameDay(minTime, time) && index == 0) {
      var maxIndex = 60 - minTime!.minute - 1;
      if (_currentRightIndex > maxIndex) {
        _currentRightIndex = maxIndex;
      }
    } else if (isAtSameDay(maxTime, time) &&
        _currentMiddleIndex == maxTime!.hour) {
      var maxIndex = maxTime!.minute;
      if (_currentRightIndex > maxIndex) {
        _currentRightIndex = maxIndex;
      }
    }
  }

  @override
  String leftStringAtIndex(int index) {
    DateTime time = currentTime.add(Duration(days: index));
    if (minTime != null &&
        time.isBefore(minTime!) &&
        !isAtSameDay(minTime, time)) {
      return "";
    } else if (maxTime != null &&
        time.isAfter(maxTime!) &&
        !isAtSameDay(maxTime, time)) {
      return "";
    }
    return formatDate(time, [ymdw], locale);
  }

  @override
  String middleStringAtIndex(int index) {
    index = index % 24;
    if (index >= 0 && index < 24) {
      DateTime time = currentTime.add(Duration(days: _currentLeftIndex));
      if (isAtSameDay(minTime, time)) {
        if (index >= 0 && index < 24 - minTime!.hour) {
          return digits(minTime!.hour + index, 2);
        } else {
          return "";
        }
      } else if (isAtSameDay(maxTime, time)) {
        if (index >= 0 && index <= maxTime!.hour) {
          return digits(index, 2);
        } else {
          return "";
        }
      }
      return digits(index, 2);
    }

    return "";
  }

  @override
  String rightStringAtIndex(int index) {
    index = index % 60;
    if (index >= 0 && index < 60) {
      DateTime time = currentTime.add(Duration(days: _currentLeftIndex));
      if (isAtSameDay(minTime, time) && _currentMiddleIndex == 0) {
        if (index >= 0 && index < 60 - minTime!.minute) {
          return digits(minTime!.minute + index, 2);
        } else {
          return "";
        }
      } else if (isAtSameDay(maxTime, time) &&
          _currentMiddleIndex >= maxTime!.hour) {
        if (index >= 0 && index <= maxTime!.minute) {
          return digits(index, 2);
        } else {
          return "";
        }
      }
      return digits(index, 2);
    }

    return "";
  }

  @override
  DateTime finalTime() {
    DateTime time = currentTime.add(Duration(days: _currentLeftIndex));
    var hour = _currentMiddleIndex;
    var minute = _currentRightIndex;
    if (isAtSameDay(minTime, time)) {
      hour += minTime!.hour;
      if (minTime!.hour == hour) {
        minute += minTime!.minute;
      }
    }

    return currentTime.isUtc
        ? DateTime.utc(time.year, time.month, time.day, hour, minute)
        : DateTime(time.year, time.month, time.day, hour, minute);
  }

  @override
  List<int> layoutProportions() {
    return [3, 1, 1];
  }

  @override
  String rightDivider() {
    return ':';
  }
}

// a range date picker model
class RangeDatePickerModel extends CommonPickerModel {
  late DateTime? maxTime;
  late DateTime? minTime;
  late DateTime? currentStartTime;
  late DateTime? currentEndTime;

  RangeDatePickerModel({
    DateTime? currentStartTime,
    DateTime? currentEndTime,
    DateTime? maxTime,
    DateTime? minTime,
    LocaleType? locale,
  }) : super(locale: locale) {
    DateTime now = DateTime.now();
    maxTime = maxTime;
    minTime = minTime;
    currentStartTime = currentStartTime;
    currentEndTime = currentEndTime;

    if (this.currentStartTime != null) {
      if (this.minTime != null && this.minTime!.isAfter(currentStartTime!)) {
        currentTime = this.minTime!;
      } else {
        currentTime = this.currentStartTime!;
      }
    } else if (this.currentEndTime != null) {
      if (this.maxTime != null && this.maxTime!.isBefore(currentStartTime!)) {
        currentTime = this.maxTime!;
      } else if (this.currentEndTime!.isBefore(now)) {
        currentTime = this.currentEndTime!;
      }
    } else if (this.minTime != null && this.minTime!.isAfter(now)) {
      currentTime = this.minTime!;
    } else if (this.maxTime != null && this.maxTime!.isBefore(now)) {
      currentTime = this.maxTime!;
    } else {
      currentTime = now;
    }

    if (this.minTime != null &&
        this.maxTime != null &&
        this.maxTime!.isBefore(this.minTime!)) {
      // invalid
      this.minTime = null;
      this.maxTime = null;
    }

    if (this.currentStartTime != null &&
        this.currentEndTime != null &&
        this.currentEndTime!.isBefore(this.currentStartTime!)) {
      // invalid
      this.currentStartTime = null;
      this.currentEndTime = null;
    }

    // default
    _currentLeftIndex = 0;
    _currentMiddleIndex = 0;
    _currentRightIndex = 0;

    if (this.currentEndTime != null) {
      DateTime from = DateTime(this.currentStartTime!.year,
          this.currentStartTime!.month, this.currentStartTime!.day);
      DateTime to = DateTime(this.currentEndTime!.year,
          this.currentEndTime!.month, this.currentEndTime!.day);

      _currentRightIndex =
          _currentLeftIndex + (to.difference(from).inHours / 24).round();
    } else {
      if (this.maxTime != null && isAtSameDay(this.maxTime!, currentTime)) {
        _currentRightIndex = _currentLeftIndex;
      } else {
        _currentRightIndex = _currentLeftIndex + 1;
      }
    }
  }

  bool isAtSameDay(DateTime? day1, DateTime? day2) {
    return day1 != null &&
        day2 != null &&
        day1.difference(day2).inDays == 0 &&
        day1.day == day2.day;
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);

    DateTime time = currentTime.add(Duration(days: index));

    if (isAtSameDay(minTime, time) && isAtSameDay(maxTime, time)) {
      setRightIndex(index);
    } else if (index >= _currentRightIndex) {
      setRightIndex(index);
    }
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);

    DateTime time = currentTime.add(Duration(days: index));

    if (isAtSameDay(minTime, time) && isAtSameDay(maxTime, time)) {
      setLeftIndex(index);
    } else if (index <= _currentLeftIndex) {
      setLeftIndex(index);
    }
  }

  @override
  String leftStringAtIndex(int index) {
    DateTime time = currentTime.add(Duration(days: index));
    if (minTime != null &&
        time.isBefore(minTime!) &&
        !isAtSameDay(minTime, time)) {
      return "";
    } else if (maxTime != null &&
        time.isAfter(maxTime!) &&
        !isAtSameDay(maxTime, time)) {
      return "";
    }
    return formatDate(time, [ymdw], locale);
  }

  @override
  String rightStringAtIndex(int index) {
    DateTime time = currentTime.add(Duration(days: index));
    if (minTime != null &&
        time.isBefore(minTime!) &&
        !isAtSameDay(minTime, time)) {
      return "";
    } else if (maxTime != null &&
        time.isAfter(maxTime!) &&
        !isAtSameDay(maxTime, time)) {
      return "";
    }
    return formatDate(time, [ymdw], locale);
  }

  @override
  List<DateTime> finalListTime() {
    List<DateTime> _result = [];

    DateTime _startTime = currentTime.add(Duration(days: _currentLeftIndex));
    DateTime _endTime = currentTime.add(Duration(days: _currentRightIndex));

    _result.add(
      currentTime.isUtc
          ? DateTime.utc(_startTime.year, _startTime.month, _startTime.day)
          : DateTime(_startTime.year, _startTime.month, _startTime.day),
    );

    _result.add(
      currentTime.isUtc
          ? DateTime.utc(_endTime.year, _endTime.month, _endTime.day)
          : DateTime(_endTime.year, _endTime.month, _endTime.day),
    );

    return _result;
  }

  @override
  List<int> layoutProportions() {
    return [1, 0, 1];
  }

  @override
  String rightDivider() {
    return '-';
  }
}
