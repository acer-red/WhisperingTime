import 'package:flutter/material.dart';
import 'package:whispering_time/pages/group/model.dart';
import 'package:whispering_time/services/http/http.dart';

class GroupsManager with ChangeNotifier {
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

  String get name => items.isNotEmpty ? items[idx].name : '';
  Group? get item => items.isNotEmpty ? items[idx] : null;
  String get id => items.isNotEmpty ? items[idx].id : '';

  Future<bool> get() async {
    final res = await Http(tid: tid).getGroups();
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
    idx = items.length - 1;
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

  void setIndex(int index) {
    if (index >= 0 && index < items.length) {
      idx = index;
      notifyListeners();
    }
  }
}
