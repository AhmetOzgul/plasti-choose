import 'package:flutter/material.dart';
import 'package:plastinder/features/professor/presentation/controllers/cleanup_controller.dart';

final class CleanupDateSelector extends StatelessWidget {
  final CleanupController controller;

  const CleanupDateSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarih Aralığı Seçin',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDateOption(context, 'Tümü', null),
            _buildDateOption(context, '1 Haftadan Eski', Duration(days: 7)),
            _buildDateOption(context, '1 Aydan Eski', Duration(days: 30)),
            _buildDateOption(context, '3 Aydan Eski', Duration(days: 90)),
            _buildDateOption(context, '6 Aydan Eski', Duration(days: 180)),
            _buildDateOption(context, '1 Yıldan Eski', Duration(days: 365)),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Özel Tarih Aralığı',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                'Başlangıç',
                controller.startDate,
                (date) => controller.setStartDate(date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                context,
                'Bitiş',
                controller.endDate,
                (date) => controller.setEndDate(date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateOption(
    BuildContext context,
    String label,
    Duration? duration,
  ) {
    final isSelected = duration == null
        ? controller.isAllSelected
        : controller.selectedDuration == duration;

    return GestureDetector(
      onTap: () => controller.selectDuration(duration),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.red.shade600 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? date,
    Function(DateTime?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Tarih seçin',
                  style: TextStyle(
                    color: date != null
                        ? Colors.grey.shade800
                        : Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
