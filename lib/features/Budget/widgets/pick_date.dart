import 'package:flutter/material.dart';

class PickDate extends StatelessWidget {
  const PickDate({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onDateChanged,
  });

  final int selectedMonth;
  final int selectedYear;
  final void Function(int month, int year) onDateChanged;

  List<DropdownMenuItem<int>> get _monthItems {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 1; i <= 12; i++) {
      items.add(DropdownMenuItem(value: i, child: Text('Tháng $i')));
    }
    return items;
  }

  List<DropdownMenuItem<int>> get _yearItems {
    List<DropdownMenuItem<int>> items = [];
    final currentYear = DateTime.now().year;
    for (int i = currentYear - 10; i <= currentYear; i++) {
      items.add(DropdownMenuItem(value: i, child: Text('Năm $i')));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<int>(
            value: selectedMonth,
            items: _monthItems,
            onChanged: (value) {
              if (value != null) {
                onDateChanged(value, selectedYear);
              }
            },
          ),
        ),
        Expanded(
          child: DropdownButton<int>(
            value: selectedYear,
            items: _yearItems,
            onChanged: (value) {
              if (value != null) {
                onDateChanged(selectedMonth, value);
              }
            },
          ),
        ),
      ],
    );
  }
}
