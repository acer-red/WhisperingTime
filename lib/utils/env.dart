
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
enum LastState {
  ok,
  err,
  delete,
  nochange,
  change,
  changeConfig,
  create,
  nocreate,
  exist,
}
extension LastStateMethods on LastState {
  bool get isErr => this == LastState.err;
}
const String appName = "whipseringtime";
const String defaultGroupName = "默认分组";

var log = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // 设置调用堆栈层级为1
  ),
);

class Level {
  static const List<String> l = ['未分类', '平淡的', '触动的', '重要的', '深刻的'];

  static String string(int index) {
    return l[index];
  }

  static Widget levelWidget(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(l[index]),
    );
  }
}

