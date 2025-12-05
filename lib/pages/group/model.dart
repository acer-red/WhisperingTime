import 'package:whispering_time/utils/time.dart';

class Group {
  String name;
  String id;
  GroupConfig config;
  DateTime updateAt;
  DateTime? overAt;

  Group(
      {required this.name,
      required this.id,
      required this.config,
      required this.updateAt,
      required this.overAt});

  @override
  String toString() {
    return "Group - id: $id, name: $name, config: viewType=${config.viewType}, isAll=${config.isAll}, isMulti=${config.isMulti}, levels=${config.levels}, autoFreezeDays=${config.autoFreezeDays}";
  }

  bool isFreezedOrBuf() => getoverAtStatus() != 0;

  int getoverAtStatus() {
    if (isManualFreezed()) {
      return 2;
    }
    if (isManualBufTime()) {
      return 1;
    }
    if (isAutoBufTime()) {
      return 1;
    }
    // 自动定格期已到
    return DateTime.now()
            .isAfter(updateAt.add(Duration(days: config.autoFreezeDays)))
        ? 2
        : 0;
  }

  bool isManualBufTime() {
    final now = DateTime.now();
    return hasManualMark() && now.isBefore(overAt!);
  }

  bool isManualFreezed() {
    final now = DateTime.now();
    return hasManualMark() && now.isAfter(overAt!);
  }

  bool isAutoBufTime() {
    final autoDeadline = updateAt.add(Duration(days: config.autoFreezeDays));
    return autoDeadline.isAfter(DateTime.now());
  }

  bool hasManualMark() {
    return overAt != null && overAt!.isBefore(Time.getForver());
  }

  bool isNotEnteroverAt() {
    return getoverAtStatus() == 0;
  }
}

class GroupConfig {
  bool isMulti;
  bool isAll;
  List<bool> levels = [];
  int viewType;
  int sortType;
  int autoFreezeDays;
  GroupConfig(
      {required this.isMulti,
      required this.isAll,
      required this.levels,
      required this.viewType,
      required this.sortType,
      required this.autoFreezeDays});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['is_multi'] = isMulti;
    data['is_all'] = isAll;
    if (levels.isNotEmpty) {
      data['levels'] = levels;
    }
    data['view_type'] = viewType;
    data['sort_type'] = sortType;
    data['auto_freeze_days'] = autoFreezeDays;
    return data;
  }

  static GroupConfig getDefault() {
    return GroupConfig(
        isAll: false,
        isMulti: false,
        levels: [true, false, false, false, false],
        viewType: 0,
        sortType: 0,
        autoFreezeDays: 30);
  }
}
