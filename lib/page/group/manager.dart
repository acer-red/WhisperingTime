import 'package:flutter/material.dart';
import 'package:whispering_time/page/group/model.dart';
import 'package:whispering_time/service/grpc/grpc.dart';

class GroupsManager with ChangeNotifier {
  String tid = '';
  final Map<String, List<Group>> _itemsMap = {};
  final Map<String, int> _indexMap = {};

  List<Group> get items => _itemsMap[tid] ?? [];
  List<Group> getItems(String themeId) => _itemsMap[themeId] ?? [];

  int get length => items.length;
  int getLength(String themeId) => getItems(themeId).length;

  int get idx => _indexMap[tid] ?? 0;
  set idx(int value) {
    _indexMap[tid] = value;
  }

  final config = GroupConfig(
      levels: [true, true, true, true, true],
      viewType: 0,
      sortType: 0,
      autoFreezeDays: 30);

  String get name =>
      items.isNotEmpty && idx < items.length ? items[idx].name : '';
  Group? get item => items.isNotEmpty && idx < items.length ? items[idx] : null;
  String get id => items.isNotEmpty && idx < items.length ? items[idx].id : '';

  Future<bool> get([String? targetTid]) async {
    final idToFetch = targetTid ?? tid;
    if (idToFetch.isEmpty) return false;

    final res = await Grpc(tid: idToFetch).getGroups();
    if (res.isNotOK) {
      return false;
    }

    final newItems = res.data
        .map((l) => Group(
              name: l.name,
              id: l.id,
              config: l.config,
              updateAt: l.updateAt,
              overAt: l.overAt,
            ))
        .toList();

    _itemsMap[idToFetch] = newItems;

    // 确保 idx 在有效范围内
    int currentIdx = _indexMap[idToFetch] ?? 0;
    if (currentIdx >= newItems.length) {
      currentIdx = newItems.length - 1;
    }
    if (currentIdx < 0) {
      currentIdx = 0;
    }
    _indexMap[idToFetch] = currentIdx;

    notifyListeners();
    return true;
  }

  void fetchForTheme(String themeId) {
    if (!_itemsMap.containsKey(themeId)) {
      get(themeId);
    }
  }

  void setThemeID(String id) {
    tid = id;
    notifyListeners();
    if (!_itemsMap.containsKey(id)) {
      get(id);
    }
  }

  void setName(String name) {
    if (items.isNotEmpty && idx < items.length) {
      items[idx].name = name;
      notifyListeners();
    }
  }

  Future<bool> add(String name, {int freezeDays = 30}) async {
    final req = RequestCreateGroup(name: name, autoFreezeDays: freezeDays);
    final res = await Grpc(tid: tid).postGroup(req);
    if (res.isNotOK) {
      return false;
    }
    final newConfig = GroupConfig.getDefault();
    newConfig.autoFreezeDays = freezeDays;
    final now = DateTime.now();

    if (!_itemsMap.containsKey(tid)) {
      _itemsMap[tid] = [];
    }

    items.add(Group(
        name: req.name,
        id: res.id,
        config: newConfig,
        updateAt: now,
        overAt: null));
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

  void setIndex(int index) {
    if (index >= 0 && index < items.length) {
      idx = index;
      notifyListeners();
    }
  }

  void setAutoFreezeDays(int days) {
    if (items.isNotEmpty && idx < items.length) {
      items[idx].config.autoFreezeDays = days;
      notifyListeners();
    }
  }

  void setoverAt(DateTime? overAt) {
    if (items.isNotEmpty && idx < items.length) {
      items[idx].overAt = overAt;
      notifyListeners();
    }
  }

  void setUpdateAt(DateTime updateAt) {
    if (items.isNotEmpty && idx < items.length) {
      items[idx].updateAt = updateAt;
      notifyListeners();
    }
  }

  void touch({String? gid, bool exitBuffer = true}) {
    final targetIndex =
        gid != null ? items.indexWhere((element) => element.id == gid) : idx;
    if (targetIndex < 0 || targetIndex >= items.length) {
      return;
    }
    items[targetIndex].updateAt = DateTime.now();
    if (exitBuffer && items[targetIndex].isManualBufTime()) {
      items[targetIndex].overAt = null;
    }
    notifyListeners();
  }

  void updateConfig() {
    notifyListeners();
  }
}
