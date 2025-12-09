import 'dart:ui';
import 'package:flutter/material.dart';

/// 时间选择滚轮组件 - 年份选择器
class YearPickerWheel extends StatelessWidget {
  final int selectedYear;
  final List<int> years;
  final ValueChanged<int> onYearChanged;
  final FixedExtentScrollController controller;
  final bool showPadding;

  const YearPickerWheel({
    super.key,
    required this.selectedYear,
    required this.years,
    required this.onYearChanged,
    required this.controller,
    this.showPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 选中区域背景
          Container(
            height: 50,
          ),
          // 滚动选择器
          ScrollConfiguration(
            behavior: _MouseScrollBehavior(),
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 50,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                if (index >= 0 && index < years.length) {
                  onYearChanged(years[index]);
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index >= years.length) return null;
                  final year = years[index];
                  final isSelected = year == selectedYear;
                  return Center(
                    child: Text(
                      year.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: isSelected ? 28 : 20,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                    ),
                  );
                },
                childCount: years.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 时间选择滚轮组件 - 月份选择器
class MonthPickerWheel extends StatelessWidget {
  final int selectedMonth;
  final List<int> months;
  final ValueChanged<int> onMonthChanged;
  final FixedExtentScrollController controller;
  final bool showPadding;

  const MonthPickerWheel({
    super.key,
    required this.selectedMonth,
    required this.months,
    required this.onMonthChanged,
    required this.controller,
    this.showPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 选中区域背景
          Container(
            height: 50,
          ),
          // 滚动选择器
          ScrollConfiguration(
            behavior: _MouseScrollBehavior(),
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 50,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                if (index >= 0 && index < months.length) {
                  onMonthChanged(months[index]);
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index >= months.length) return null;
                  final month = months[index];
                  final isSelected = month == selectedMonth;
                  return Center(
                    child: Text(
                      showPadding
                          ? month.toString().padLeft(2, '0')
                          : month.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: isSelected ? 28 : 20,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                    ),
                  );
                },
                childCount: months.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MouseScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
