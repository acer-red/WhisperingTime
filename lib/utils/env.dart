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

enum IMGType {
  jpg,
  png,
}

// 这里的顺序要对应Dropdown组件的顺序
enum FeedbackType {
  optFeature, // 优化功能
  bug, // 问题缺陷
  newFeature, // 新增功能
  other, // 其他
}

extension LastStateMethods on LastState {
  bool get isErr => this == LastState.err;
}

const String appNameEn = "whisperingtime";
const String appNameEnHuman = "Whispering Time";
const String appNameZh = "枫迹";
const String appNameZhHuman = "枫 迹";
const String defaultGroupName = "默认分组";

var log = Logger(
  printer: PrettyPrinter(
    methodCount: 4,
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

class Avatar {
  String name;
  String url;
  Avatar({required this.name, required this.url});
  factory Avatar.fromJson(Map<String, dynamic> g) {
    return Avatar(name: g['name'], url: g['url']);
  }
}

class Profile {
  String nickname;
  Avatar avatar;
  Profile({required this.nickname, required this.avatar});
  factory Profile.fromJson(Map<String, dynamic> g) {
    return Profile(
        nickname: g['nickname'], avatar: Avatar.fromJson(g['avatar']));
  }
}

class UserBasicInfo {
  final String email;
  final Profile profile;
  UserBasicInfo({required this.email, required this.profile});
}

class API {
  String key;
  String expiresAt;
  API({required this.key, required this.expiresAt});
  factory API.fromJson(Map<String, dynamic> g) {
    return API(
      key: g['apikey'],
      expiresAt: g['expiresAt'],
    );
  }
}
