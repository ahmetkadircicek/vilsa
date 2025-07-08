import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/constants/general_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';

class CustomDatePicker extends StatelessWidget {
  final String title;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? icon;

  const CustomDatePicker({
    super.key,
    required this.title,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        // color: context.surfaceContainer,
        borderRadius: GeneralConstants.instance.borderRadius,
      ),
      child: Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: firstDate ?? DateTime(2020),
              lastDate: lastDate ?? DateTime.now(),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: context.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Helper(
                      text: title,
                      color: context.onSurface,
                    ),
                    Content(
                      text:
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      color: context.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDateRangePicker extends StatelessWidget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime, DateTime) onDateRangeSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? icon;

  const CustomDateRangePicker({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
    this.firstDate,
    this.lastDate,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: GeneralConstants.instance.borderRadius,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: GeneralConstants.instance.borderRadius,
        ),
        child: GestureDetector(
          onTap: () async {
            final pickedDateRange = await showDateRangePicker(
              context: context,
              firstDate: firstDate ?? DateTime(2020),
              lastDate: lastDate ?? DateTime.now(),
              initialDateRange: DateTimeRange(start: startDate, end: endDate),
            );
            if (pickedDateRange != null) {
              onDateRangeSelected(pickedDateRange.start, pickedDateRange.end);
            }
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: context.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Helper(
                      text: title,
                      color: context.onSurface,
                    ),
                    Content(
                      text:
                          '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
                      color: context.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
