import 'package:whispering_time/utils/time.dart';

class Group {
  String name;
  String id;
  DateTime overAt;
  GroupConfig config;

  Group(
      {required this.name,
      required this.id,
      required this.overAt,
      required this.config});

  // 判断当前时间是否在overAt的之内
  bool isBufTime() {
    DateTime now = DateTime.now();
    return now.isBefore(overAt) && now.isBefore(overAt.add(Time.getoverAt()));
  }

  // 判断当前时间是否在overAt之后
  bool isEnteroverAt() {
    return DateTime.now().isAfter(overAt);
  }

  // 判断当前时间是否在overAt之前
  bool isNotEnteroverAt() {
    DateTime oneDayBefore = overAt.subtract(Time.getoverAt());
    return DateTime.now().isBefore(oneDayBefore);
  }

  int getoverAtStatus() {
    // 顺序不能修改
    if (isNotEnteroverAt()) {
      return 0;
    }
    if (isBufTime()) {
      return 1;
    }
    return 2;
  }

  bool isFreezedOrBuf() {
    return getoverAtStatus() != 0;
  }

  @override
  String toString() {
    return "Group - id: $id, name: $name, overAt: $overAt, config: viewType=${config.viewType}, isAll=${config.isAll}, isMulti=${config.isMulti}, levels=${config.levels}";
  }
}

class GroupConfig {
  bool isMulti;
  bool isAll;
  List<bool> levels = [];
  int viewType;
  int sortType;
  GroupConfig(
      {required this.isMulti,
      required this.isAll,
      required this.levels,
      required this.viewType,
      required this.sortType});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['is_multi'] = isMulti;
    data['is_all'] = isAll;
    if (levels.isNotEmpty) {
      data['levels'] = levels;
    }
    data['view_type'] = viewType;
    data['sort_type'] = sortType;
    return data;
  }

  static GroupConfig getDefault() {
    return GroupConfig(
        isAll: false,
        isMulti: false,
        levels: [true, false, false, false, false],
        viewType: 0,
        sortType: 0);
  }
}
