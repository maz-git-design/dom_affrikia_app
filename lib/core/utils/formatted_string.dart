import 'package:basic_utils/basic_utils.dart';

String splitDate(String date) {
  var dateSplited = date.split('-');

  try {
    dateSplited[2] = dateSplited[2].split('T')[0];
    return dateSplited[2] + '/' + dateSplited[1] + '/' + dateSplited[0];
  } catch (_) {
    return '';
  }
}

DateTime dateSringToDateTime(String date) {
  var dateSplited = date.split('-');

  try {
    dateSplited[2] = dateSplited[2].split('T')[0];
    // var hour = dateSplited[2].split('T')[1];
    // hour = hour.split('.')[0];
    var newDate = dateSplited[0] + '-' + dateSplited[1] + '-' + dateSplited[2];
    return DateTime.parse(newDate);
  } catch (_) {
    return DateTime.now();
  }
}

DateTime dateSringFromSlashFormatToDateTime(String date) {
  var dateSplited = date.split('/');

  var year = dateSplited[2].split(' ')[0];
  var month = dateSplited[1];
  var day = dateSplited[0];
  var hour = dateSplited[2].split(' ')[1];
  var newDate = year + '-' + month + '-' + day + ' ' + hour;
  return DateTime.parse(newDate);
}

String dateSringFromSlashFormatToDate(String date) {
  var dateSplited = date.split('/');

  var year = dateSplited[2];
  var month = dateSplited[1];
  var day = dateSplited[0];
  //var hour = dateSplited[2].split(' ')[1];
  var newDate = year + '-' + month + '-' + day;
  return newDate;
}

String dateSlashFormat(String date) {
  var dateSplited = date.split('-');

  try {
    return dateSplited[2] + '/' + dateSplited[1] + '/' + dateSplited[0];
  } catch (_) {
    return '';
  }
}

String nameShortFormat(String name) {
  var nameSplited = name.split(' ');
  List<String> nameFormattedList = [];

  if (nameSplited.length <= 1) {
    return name;
  } else {
    nameFormattedList.add(nameSplited[0]);
    nameFormattedList.add(nameSplited[1].substring(0, 1) + '.');

    return nameFormattedList.join(' ');
  }
}

String formattedName(String name) {
  if (name == '') {
    return '';
  }
  var nameSplited = name.split(' ');
  List<String> nameFormattedList;

  if (nameSplited.length <= 1) {
    return name;
  } else {
    nameFormattedList = nameSplited.map((name) => StringUtils.capitalize(name)).toList();
    return nameFormattedList.join(' ');
  }
}
