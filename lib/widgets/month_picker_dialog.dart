import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';

class MonthPickerDialog extends StatefulWidget {
  final String initialMonthKey;
  final ValueChanged<String> onMonthSelected;

  const MonthPickerDialog({
    super.key,
    required this.initialMonthKey,
    required this.onMonthSelected,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final dt = AppFormatters.parseMonthKey(widget.initialMonthKey);
    _selectedYear = dt.year;
    _selectedMonth = dt.month;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            onPressed: () => setState(() => _selectedYear--),
          ),
          Text(
            '$_selectedYear',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onPressed: () => setState(() => _selectedYear++),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        height: 230,
        child: GridView.builder(
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            final monthNumber = index + 1;
            final isSelected = monthNumber == _selectedMonth;
            final monthName = DateFormat('MMM').format(DateTime(_selectedYear, monthNumber, 1));

            return InkWell(
              onTap: () {
                setState(() => _selectedMonth = monthNumber);
                final formattedMonth = monthNumber.toString().padLeft(2, '0');
                final monthKey = '$_selectedYear-$formattedMonth';
                widget.onMonthSelected(monthKey);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey.shade200 : Colors.black87),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('বাতিল'),
        ),
      ],
    );
  }
}

