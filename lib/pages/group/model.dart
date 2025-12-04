import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/http.dart';
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

class GroupsModel with ChangeNotifier {
  String tid = '';
  List<Group> items = [];
  int get length => items.length;
  int idx = 0;
  final config = GroupConfig(
      isAll: false,
      isMulti: false,
      levels: [true, true, true, true, true],
      viewType: 0,
      sortType: 0);
  // 添加边界检查的安全 getter
  String get name => items.isNotEmpty ? items[idx].name : '';
  Group? get item => items.isNotEmpty ? items[idx] : null;
  String get id => items.isNotEmpty ? items[idx].id : '';

  Future<bool> get() async {
    final res = await Http(tid: tid).getGroups();
    // 修复逻辑：应该检查 isEmpty，并更新 items
    if (res.isNotOK || res.data.isEmpty) {
      return false;
    }

    items = res.data
        .map((l) =>
            Group(name: l.name, id: l.id, overAt: l.overAt, config: l.config))
        .toList();

    // 确保 idx 在有效范围内
    if (idx >= items.length) {
      idx = items.length - 1;
    }
    if (idx < 0) {
      idx = 0;
    }

    notifyListeners();
    return true;
  }

  void setThemeID(String id) {
    tid = id;
    notifyListeners();
    get();
  }

  void setName(String name) {
    if (items.isNotEmpty && idx < items.length) {
      items[idx].name = name;
      notifyListeners();
    }
  }

  Future<bool> add(String name) async {
    final req = RequestPostGroup(name: name);
    final res = await Http(tid: tid).postGroup(req);
    if (res.isNotOK) {
      return false;
    }
    items.add(
        Group(name: req.name, id: res.id, overAt: req.overAt, config: config));
    idx = items.length - 1; // 新增后将 idx 设置为最后一个
    notifyListeners();
    return true;
  }

  void removeAt(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      // 调整 idx 避免越界
      if (idx >= items.length && items.isNotEmpty) {
        idx = items.length - 1;
      }
      if (items.isEmpty) {
        idx = 0;
      }
      notifyListeners();
    }
  }

  void setoverAt(DateTime overAt) {
    if (items.isNotEmpty && idx < items.length) {
      items[idx].overAt = overAt;
      notifyListeners();
    }
  }

  // 添加设置当前索引的方法
  void setIndex(int index) {
    if (index >= 0 && index < items.length) {
      idx = index;
      notifyListeners();
    }
  }
}
