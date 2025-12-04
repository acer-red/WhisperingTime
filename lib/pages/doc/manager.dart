import 'package:flutter/foundation.dart';
import 'package:whispering_time/pages/doc/model.dart';
import 'package:whispering_time/pages/group/model.dart';
import 'package:whispering_time/services/http/http.dart';

class DocsManager extends ChangeNotifier {
  final String groupId;

  // 从服务器获取的所有原始数据。
  List<Doc> _allFetchedDocs = [];

  // 展示列表
  List<Doc> _items = [];

  // 缓存的可用年份和月份
  final Set<int> _availableYears = {};
  final Map<int, Set<int>> _availableMonths = {};

  List<Doc> get items => _items;
  List<Doc> get allFetchedDocs => _allFetchedDocs;

  DocsManager(this.groupId);

  // 获取数据
  Future<void> fetchDocs(
      {int? year, int? month, required GroupConfig config}) async {
    final ret = await Http(gid: groupId).getDocs(year, month);
    _allFetchedDocs = ret.data;

    // 如果是获取全部数据，则更新缓存
    if (year == null && month == null) {
      _availableYears.clear();
      _availableMonths.clear();
      for (var doc in _allFetchedDocs) {
        _addToCache(doc);
      }
    }

    filterAndSort(config);
  }

  void _addToCache(Doc doc) {
    _availableYears.add(doc.createAt.year);
    if (!_availableMonths.containsKey(doc.createAt.year)) {
      _availableMonths[doc.createAt.year] = {};
    }
    _availableMonths[doc.createAt.year]!.add(doc.createAt.month);
  }

  // 筛选和排序逻辑
  void filterAndSort(GroupConfig config) {
    _items.clear();

    // 筛选逻辑
    if (!isNoSelectLevel(config)) {
      for (Doc doc in _allFetchedDocs) {
        if (isContainSelectLevel(doc.level, config)) {
          _items.add(doc);
        }
      }
    }

    // 排序逻辑
    _items.sort((a, b) => compareDocs(a, b, config));

    notifyListeners();
  }

  int compareDocs(Doc a, Doc b, GroupConfig config) {
    if (config.sortType == 1) {
      return a.updateAt.compareTo(b.updateAt);
    }
    return a.createAt.compareTo(b.createAt);
  }

  bool isNoSelectLevel(GroupConfig config) {
    for (bool one in config.levels) {
      if (one) {
        return false;
      }
    }
    return true;
  }

  bool isContainSelectLevel(int i, GroupConfig config) {
    if (i < 0 || i >= config.levels.length) return false;
    return config.levels[i];
  }

  // 插入新文档
  void insertDoc(Doc doc) {
    _allFetchedDocs.insert(0, doc);
    _items.insert(0, doc);
    _addToCache(doc);
    notifyListeners();
  }

  // 更新文档
  void updateDoc(Doc oldDoc, Doc newDoc, GroupConfig config) {
    _addToCache(newDoc);
    // Sync _allFetchedDocs
    int allIndex = _allFetchedDocs.indexOf(oldDoc);
    if (allIndex != -1) {
      _allFetchedDocs[allIndex] = newDoc;
    } else {
      if (oldDoc.id.isNotEmpty) {
        allIndex = _allFetchedDocs.indexWhere((d) => d.id == oldDoc.id);
        if (allIndex != -1) {
          _allFetchedDocs[allIndex] = newDoc;
        }
      }
    }

    // 在 items 中找到 oldDoc 的位置
    int itemIndex = _items.indexOf(oldDoc);
    if (itemIndex != -1) {
      // 如果不符合选中的级别筛选，则删除
      if (!isContainSelectLevel(newDoc.level, config)) {
        _items.removeAt(itemIndex);
      } else {
        _items[itemIndex] = newDoc;
        _items.sort((a, b) => compareDocs(a, b, config));
      }
    } else {
      // 如果 items 里没有（可能之前被筛选掉了），但现在符合条件了
      if (isContainSelectLevel(newDoc.level, config)) {
        _items.add(newDoc);
        _items.sort((a, b) => compareDocs(a, b, config));
      }
    }
    notifyListeners();
  }

  // 删除文档
  void removeDoc(Doc doc) {
    _items.remove(doc);
    _allFetchedDocs.removeWhere((d) => d.id == doc.id);
    notifyListeners();
  }

  // 仅仅从 items 和 allFetchedDocs 移除（例如取消新建）
  void removeDocFromItemsAndAll(Doc doc) {
    _items.remove(doc);
    _allFetchedDocs.remove(doc);
    notifyListeners();
  }

  List<int> getAvailableYears() {
    if (_availableYears.isNotEmpty) {
      return _availableYears.toList()..sort();
    }
    final years = <int>{};

    for (var doc in _allFetchedDocs) {
      years.add(doc.createAt.year);
    }

    return years.toList()..sort();
  }

  List<String> getAvailableMonth(int year) {
    if (_availableMonths.containsKey(year)) {
      return _availableMonths[year]!
          .map((e) => e.toString().padLeft(2, '0'))
          .toList()
        ..sort();
    }
    final months = <String>{};

    for (var doc in _allFetchedDocs) {
      if (doc.createAt.year == year) {
        months.add(doc.createAt.month.toString().padLeft(2, '0'));
      }
    }

    return months.toList()..sort();
  }
}
