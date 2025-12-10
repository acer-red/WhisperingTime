import 'package:flutter/material.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/util/ui.dart';

class FilterBottomSheet extends StatefulWidget {
  final int initialViewType;
  final int initialSortType;
  final List<bool> initialLevels;
  final Function(int, int, List<bool>) onChanged;

  const FilterBottomSheet({
    Key? key,
    required this.initialViewType,
    required this.initialSortType,
    required this.initialLevels,
    required this.onChanged,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late int viewType;
  late int sortType;
  late List<bool> levels;

  @override
  void initState() {
    super.initState();
    viewType = widget.initialViewType;
    sortType = widget.initialSortType;
    levels = List.from(widget.initialLevels);
  }

  void _updateState(VoidCallback fn) {
    setState(fn);
    widget.onChanged(viewType, sortType, levels);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          ShortGreyLine(),
          SizedBox(height: 10),
          // View Mode
          ListTile(
            title: Text('视图模式'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: Text('卡片'),
                  selected: viewType == 0,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => viewType = 0);
                    }
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('日历'),
                  selected: viewType == 1,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => viewType = 1);
                    }
                  },
                ),
              ],
            ),
          ),
          // Sort Mode
          ListTile(
            title: Text('排序模式'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: Text('创建时间'),
                  selected: sortType == 0,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => sortType = 0);
                    }
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('更新时间'),
                  selected: sortType == 1,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => sortType = 1);
                    }
                  },
                ),
              ],
            ),
          ),
          // Level Selection
          ExpansionTile(
            title: Text('分级筛选'),
            children: List.generate(Level.l.length, (index) {
              return CheckboxListTile(
                title: Text(Level.l[index]),
                value: levels[index],
                onChanged: (bool? value) {
                  if (value != null) {
                    _updateState(() => levels[index] = value);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
