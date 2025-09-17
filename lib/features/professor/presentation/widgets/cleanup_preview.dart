import 'package:flutter/material.dart';
import 'package:plastinder/features/professor/presentation/controllers/cleanup_controller.dart';

final class CleanupPreview extends StatelessWidget {
  final CleanupController controller;

  const CleanupPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.selectedPatientsCount <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            '${controller.selectedPatientsCount} hasta silinecek',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
