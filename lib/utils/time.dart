import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Time {
  static DateTime datetime(String t) {
    if (t.isEmpty) {
      return DateTime.now();
    }
    int timestamp = int.parse(t);

    return DateTime.fromMillisecondsSinceEpoch(timestamp *= 1000);
  }

  static String string(DateTime t) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(t);
  }

  static DateTime stringToTime(String t) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    // 获取北京时区
    // tz.Location beijing = tz.getLocation('Asia/Shanghai');
    // 将 UTC 时间转换为北京时间
    // DateTime beijingTime = tz.TZDateTime.from(utcTime, beijing);
    return formatter.parse(t, false);
  }

  static DateTime stringToTimeHasT(String t) {
    return DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(t, false);
  }

  static String nowTimestampString() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
  }

  static String toTimestampString(DateTime t) {
    return (t.millisecondsSinceEpoch / 1000).round().toString();
  }

  static DateTime getForver() {
    return DateTime.now().add(const Duration(days: 36500));
  }

  // 定格时间设置
  static Duration getOverTime() {
    return const Duration(days: 7);
  }

  static DateTime getOverDay() {
    return DateTime.now().add(Time.getOverTime());
  }

  static Future<DateTime?> datePacker(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );
  }

  static String getCurrentTime() {
    return DateFormat('yyyy年MM月dd日HH时mm分ss秒').format(DateTime.now());
  }
}
