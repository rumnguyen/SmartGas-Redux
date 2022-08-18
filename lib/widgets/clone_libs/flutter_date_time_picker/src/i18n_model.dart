enum LocaleType {
  en,
  vi,
}

final _i18nModel = <LocaleType, Map<String, Object>>{
  LocaleType.en: {
    'titlePickDate': 'Pick date',
    'titlePickDateTime': 'Pick date time',
    'titlePickTime': 'Pick time',
    'titlePickRangeDate': 'Pick range date',
    'cancel': 'Cancel',
    'done': 'Done',
    'today': 'Today',
    'monthShort': [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ],
    'monthLong': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],
    'day': ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'],
    'dayLong': [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ],
    'am': 'AM',
    'pm': 'PM'
  },
  LocaleType.vi: {
    'titlePickDate': 'Chọn ngày',
    'titlePickDateTime': 'Chọn ngày giờ',
    'titlePickTime': 'Chọn thời gian',
    'titlePickRangeDate': 'Chọn khoảng thời gian',
    'cancel': 'Hủy bỏ',
    'done': 'Xong',
    'today': 'Hôm nay',
    'monthShort': [
      'Thg 1',
      'Thg 2',
      'Thg 3',
      'Thg 4',
      'Thg 5',
      'Thg 6',
      'Thg 7',
      'Thg 8',
      'Thg 9',
      'Thg 10',
      'Thg 11',
      'Thg 12'
    ],
    'monthLong': [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ],
    'day': ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
    'dayLong': [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ Nhật'
    ],
    'am': 'SA',
    'pm': 'CH'
  },
};

/// Get international object for [localeType]
Map<String, Object>? i18nObjInLocale(LocaleType localeType) =>
    _i18nModel[localeType] ?? _i18nModel[LocaleType.en];

/// Get international lookup for a [localeType], [key] and [index].
String i18nObjInLocaleLookup(LocaleType localeType, String key, int index) {
  final i18n = i18nObjInLocale(localeType);
  final i18nKey = i18n![key] as List<String>;
  return i18nKey[index];
}
