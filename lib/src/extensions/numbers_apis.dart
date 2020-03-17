import 'package:date_format/date_format.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/l10n/l10n.dart';

const _kilobyte = 1024;
const _megabyte = 1024 * _kilobyte;

extension Convert on int {
  String byteToPrintableSize() {
    String unit;
    double result;
    if (this < _kilobyte) {
      result = this.toDouble();
      unit = "Byte";
    } else if (this < _megabyte) {
      result = this / _kilobyte;
      unit = "KB";
    } else {
      result = this / _megabyte;
      unit = "MB";
    }
    return "${result.toStringAsFixed(2)} $unit";
  }
}

extension Date on int {
  static const formatterDateAndTime = [dd, '.', mm, '.', yyyy, ' - ', HH, ':', nn];
  static const formatterTime = [HH, ':', nn];
  static const formatterDate = [dd, '.', mm];
  static const formatterDateLong = [dd, '. ', MM];
  static const formatterTimer = [nn, ':', ss];
  static const formatterVideoTime = [n, ':', ss];
  static const formatterDateTimeFile = [yy, '-', mm, '-', dd, '_', HH, '-', nn, '-', ss];

  String getTimeFormTimestamp() {
    return formatDate(this._getDateTimeFromTimestamp(), formatterTime);
  }

  DateTime _getDateTimeFromTimestamp() => DateTime.fromMillisecondsSinceEpoch(this);

  String getDateFromTimestamp(bool longMonth, [bool prependWordsWhereApplicable]) {
    var date = formatDate(this._getDateTimeFromTimestamp(), longMonth ? formatterDateLong : formatterDate);
    if (prependWordsWhereApplicable != null && prependWordsWhereApplicable) {
      if (getNowTimestamp()._compareDate(this) == 0) {
        return "${L10n.get(L.today)} - $date";
      } else if (getYesterdayTimestamp()._compareDate(this) == 0) {
        return "${L10n.get(L.yesterday)} - $date";
      }
    }
    return date;
  }

  int _compareDate(int timestampTwo) {
    var dateOne = this._getDateTimeFromTimestamp();
    var dateOneCompare = DateTime(dateOne.year, dateOne.month, dateOne.day);
    var dateTwo = timestampTwo._getDateTimeFromTimestamp();
    var dateTwoCompare = DateTime(dateTwo.year, dateTwo.month, dateTwo.day);
    return dateOneCompare.compareTo(dateTwoCompare);
  }

  String getTimerFromTimestamp() {
    return formatDate(this._getDateTimeFromTimestamp(), formatterTimer);
  }

  String getChatListTime() {
    if (getNowTimestamp()._compareDate(this) == 0) {
      return this.getTimeFormTimestamp();
    } else if (getYesterdayTimestamp()._compareDate(this) == 0) {
      return L10n.get(L.yesterday);
    } else {
      return formatDate(this._getDateTimeFromTimestamp(), formatterDate);
    }
  }

  String getDateTimeFileFormTimestamp() {
    return formatDate(this._getDateTimeFromTimestamp(), formatterDateTimeFile);
  }

  String getDateAndTimeFromTimestamp() {
    return formatDate(this._getDateTimeFromTimestamp(), formatterDateAndTime);
  }

  String getVideoTimeFromTimestamp() {
    return formatDate(this._getDateTimeFromTimestamp(), formatterVideoTime);
  }
}

String getDateTimeFileFormTimestamp() {
  return getNowTimestamp().getDateTimeFileFormTimestamp();
}

int getNowTimestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}

int getYesterdayTimestamp() {
  return DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch;
}
