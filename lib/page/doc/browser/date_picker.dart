import 'package:flutter/material.dart';
import 'package:whispering_time/page/doc/manager.dart';
import 'package:whispering_time/util/picker_wheel.dart';

class DocDatePickerDialog extends StatefulWidget {
  final DocsManager docsManager;
  final DateTime initialDate;
  final ValueChanged<DateTime> onConfirm;

  const DocDatePickerDialog({
    Key? key,
    required this.docsManager,
    required this.initialDate,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _DocDatePickerDialogState createState() => _DocDatePickerDialogState();
}

class _DocDatePickerDialogState extends State<DocDatePickerDialog> {
  late int selectedYear;
  late int selectedMonth;
  late List<int> years;
  late List<int> months;
  late FixedExtentScrollController yearController;
  late FixedExtentScrollController monthController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;

    years = widget.docsManager.getAvailableYears();
    if (years.isEmpty) {
      years = [DateTime.now().year];
    }
    if (!years.contains(selectedYear)) {
      selectedYear = years.first;
    }

    _updateMonths();

    yearController = FixedExtentScrollController(
        initialItem:
            years.contains(selectedYear) ? years.indexOf(selectedYear) : 0);
    monthController = FixedExtentScrollController(
        initialItem:
            months.contains(selectedMonth) ? months.indexOf(selectedMonth) : 0);
  }

  void _updateMonths() {
    List<String> monthStrs = widget.docsManager.getAvailableMonth(selectedYear);
    months = monthStrs.map((e) => int.parse(e)).toList();
    if (months.isEmpty) {
      months = [1];
    }
    if (!months.contains(selectedMonth)) {
      selectedMonth = months.first;
    }
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  widget.onConfirm(DateTime(selectedYear, selectedMonth));
                  Navigator.pop(context);
                },
                child: Text('确定'),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                YearPickerWheel(
                  selectedYear: selectedYear,
                  years: years,
                  controller: yearController,
                  onYearChanged: (year) {
                    setState(() {
                      selectedYear = year;
                      _updateMonths();
                      // Reset month controller if needed or jump to new index
                      if (months.contains(selectedMonth)) {
                        monthController
                            .jumpToItem(months.indexOf(selectedMonth));
                      } else {
                        monthController.jumpToItem(0);
                      }
                    });
                  },
                ),
                MonthPickerWheel(
                  selectedMonth: selectedMonth,
                  months: months,
                  controller: monthController,
                  onMonthChanged: (month) {
                    setState(() {
                      selectedMonth = month;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
