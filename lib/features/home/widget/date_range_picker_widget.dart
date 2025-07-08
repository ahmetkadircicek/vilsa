import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/components/custom_date_picker.dart';
import 'package:vilsa/core/components/general_text.dart';
import 'package:vilsa/core/components/section_container.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/features/home/viewmodel/home_view_model.dart';

class DateRangePickerWidget extends StatelessWidget {
  const DateRangePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return _buildDateSection(context, viewModel);
      },
    );
  }
}

Widget _buildDateSection(BuildContext context, HomeViewModel viewModel) {
  return SectionContainer(
    title: Label(
      text: "Tarih Seçimi",
      isBold: true,
      fontSize: 14,
      color: context.primary,
    ),
    content: CustomDateRangePicker(
      title: 'Tarih Aralığı',
      startDate: viewModel.startDate,
      endDate: viewModel.endDate,
      onDateRangeSelected: (start, end) {
        viewModel.setDateRange(start, end);
      },
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ),
  );
}
