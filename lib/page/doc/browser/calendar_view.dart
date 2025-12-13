import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/page/doc/manager.dart';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/doc/browser/date_picker.dart';
import 'package:whispering_time/page/doc/browser/bubble.dart';

class DocCalendarView extends StatefulWidget {
  final DocsManager docsManager;
  final DateTime pickedDate;
  final Set<String> expandedRanges;
  final Map<String, GlobalKey> monthKeys;
  final Function(DateTime) onDatePicked;
  final Function(String) onGapExpanded;
  final Function(Doc) onEdit;
  final Function(Doc) onSetting;

  const DocCalendarView({
    super.key,
    required this.docsManager,
    required this.pickedDate,
    required this.expandedRanges,
    required this.monthKeys,
    required this.onDatePicked,
    required this.onGapExpanded,
    required this.onEdit,
    required this.onSetting,
  });

  @override
  State<DocCalendarView> createState() => _DocCalendarViewState();
}

class _DocCalendarViewState extends State<DocCalendarView> {
  @override
  Widget build(BuildContext context) {
    // 使用allFetchedDocs来计算日期范围，确保所有文档（包括被筛选掉的）都能显示其月份
    if (widget.docsManager.allFetchedDocs.isEmpty) {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              _buildWeekHeaderWithPadding(),
              _buildMonthRow(DateTime.now()),
            ],
          ),
        ),
      );
    }

    DateTime minDate = widget.docsManager.allFetchedDocs.first.createAt;
    DateTime maxDate = widget.docsManager.allFetchedDocs.first.createAt;
    for (var doc in widget.docsManager.allFetchedDocs) {
      if (doc.createAt.isBefore(minDate)) minDate = doc.createAt;
      if (doc.createAt.isAfter(maxDate)) maxDate = doc.createAt;
    }

    if (widget.pickedDate.isBefore(minDate)) minDate = widget.pickedDate;
    if (widget.pickedDate.isAfter(maxDate)) maxDate = widget.pickedDate;

    minDate = DateTime(minDate.year, minDate.month);
    maxDate = DateTime(maxDate.year, maxDate.month);

    List<Widget> children = [];
    children.add(_buildWeekHeaderWithPadding());

    List<DateTime> gapMonths = [];

    void flushGap() {
      if (gapMonths.isEmpty) return;
      String gapId =
          "${gapMonths.first.millisecondsSinceEpoch}-${gapMonths.last.millisecondsSinceEpoch}";
      if (widget.expandedRanges.contains(gapId)) {
        for (var date in gapMonths) {
          children.add(_buildMonthRow(date));
        }
      } else {
        children.add(_buildGapButton(gapId, gapMonths));
      }
      gapMonths.clear();
    }

    DateTime current = minDate;
    while (current.isBefore(maxDate) ||
        current.year == maxDate.year && current.month == maxDate.month) {
      bool hasDocs = widget.docsManager.allFetchedDocs.any((d) =>
          d.createAt.year == current.year && d.createAt.month == current.month);
      bool isPicked = current.year == widget.pickedDate.year &&
          current.month == widget.pickedDate.month;

      if (hasDocs || isPicked) {
        flushGap();
        String keyStr = "${current.year}-${current.month}";
        GlobalKey key = widget.monthKeys.putIfAbsent(keyStr, () => GlobalKey());
        children.add(_buildMonthRow(current, key: key));
      } else {
        gapMonths.add(current);
      }

      current = DateTime(current.year, current.month + 1);
    }
    flushGap();

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width,
        child: ListView(
          padding: EdgeInsets.only(right: 12),
          children: children,
        ),
      ),
    );
  }

  void _chooseDate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: DocDatePickerDialog(
            docsManager: widget.docsManager,
            initialDate: widget.pickedDate,
            onConfirm: (DateTime date) {
              widget.onDatePicked(date);
            },
          ),
        );
      },
    );
  }

  Widget _buildWeekHeaderWithPadding() {
    return Row(
      children: [
        SizedBox(width: 44),
        Expanded(child: _buildWeekHeader()),
      ],
    );
  }

  Widget _buildWeekHeader() {
    return SizedBox(
      height: 30,
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 2.0,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            return Align(
                alignment: Alignment.center,
                child: Text(_getWeekString(index),
                    style: TextStyle(fontSize: 12)));
          }),
    );
  }

  Widget _buildMonthRow(DateTime date, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            child: _buildMonthSideHeader(date),
          ),
          Expanded(child: _buildMonthGrid(date)),
        ],
      ),
    );
  }

  Widget _buildMonthSideHeader(DateTime date) {
    return InkWell(
      onTap: _chooseDate,
      child: Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('MM').format(date),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown),
            ),
            Text(
              DateFormat('yyyy').format(date),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGapButton(String gapId, List<DateTime> months) {
    return TextButton(
      onPressed: () {
        widget.onGapExpanded(gapId);
      },
      child: Icon(Icons.more_horiz),
    );
  }

  Widget _buildMonthGrid(DateTime date) {
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    int firstWeekdayOfMonth = DateTime(date.year, date.month, 1).weekday;
    int totalRows = ((daysInMonth + firstWeekdayOfMonth - 1) / 7).ceil();
    int totalitems = totalRows * 7;

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
      ),
      itemCount: totalitems,
      itemBuilder: (context, index) {
        int dayNumber = index - firstWeekdayOfMonth + 2;
        if (!(dayNumber > 0 && dayNumber <= daysInMonth)) {
          return Container();
        }

        List<Doc> dayDocs = [];
        for (var d in widget.docsManager.items) {
          if (d.createAt.year == date.year &&
              d.createAt.month == date.month &&
              d.createAt.day == dayNumber) {
            dayDocs.add(d);
          }
        }

        bool istoday = dayNumber == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;

        if (dayDocs.isNotEmpty) {
          return _grid(istoday, dayNumber, dayDocs);
        } else {
          return _gridNoFlag(istoday, dayNumber);
        }
      },
    );
  }

  Widget _grid(bool istoday, int dayNumber, List<Doc> dayDocs) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () => showDocsBubble(
          context: context,
          docs: dayDocs,
          onEdit: widget.onEdit,
          onSetting: widget.onSetting,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "$dayNumber",
                  style: TextStyle(
                      fontSize: 18,
                      color: istoday ? Colors.blue : Colors.black,
                      fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
                ),
                Icon(
                  Icons.star_rounded,
                  size: 10,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _gridNoFlag(bool istoday, int dayNumber) {
    return GestureDetector(
      child: Align(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "$dayNumber",
                style: TextStyle(
                    fontSize: 18,
                    color: istoday ? Colors.blue : Colors.grey,
                    fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
              ),
              Icon(
                Icons.star_rounded,
                size: 10,
                color: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeekString(int index) {
    switch (index) {
      case 0:
        return "周一";
      case 1:
        return "周二";
      case 2:
        return "周三";
      case 3:
        return "周四";
      case 4:
        return "周五";
      case 5:
        return "周六";
      default:
        return "周日";
    }
  }
}
