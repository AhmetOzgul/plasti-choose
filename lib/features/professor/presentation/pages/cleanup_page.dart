import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/features/professor/presentation/controllers/cleanup_controller.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/core/widgets/modern_snackbar.dart';
import 'package:plastinder/features/professor/presentation/widgets/cleanup_warning_card.dart';
import 'package:plastinder/features/professor/presentation/widgets/cleanup_date_selector.dart';
import 'package:plastinder/features/professor/presentation/widgets/cleanup_options.dart';
import 'package:plastinder/features/professor/presentation/widgets/cleanup_preview.dart';
import 'package:plastinder/features/professor/presentation/widgets/cleanup_actions.dart';

final class CleanupPage extends StatelessWidget {
  const CleanupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CleanupController>(
      create: (_) {
        final repository = context.read<ProfessorPatientRepository>();
        final authController = context.read<AuthController>();
        return CleanupController(repository, authController);
      },
      child: const _CleanupPageContent(),
    );
  }
}

final class _CleanupPageContent extends StatelessWidget {
  const _CleanupPageContent();

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              secondary.withOpacity(0.05),
              tertiary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Consumer<CleanupController>(
                    builder: (context, controller, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CleanupWarningCard(),
                          const SizedBox(height: 24),
                          CleanupDateSelector(controller: controller),
                          const SizedBox(height: 24),
                          CleanupOptions(controller: controller),
                          const Spacer(),
                          CleanupPreview(controller: controller),
                          const SizedBox(height: 16),
                          CleanupActions(
                            controller: controller,
                            onDelete: () => _handleDelete(context, controller),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 8),
          Text(
            'Temizlik',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Icon(Icons.cleaning_services, color: Colors.red.shade400, size: 24),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    CleanupController controller,
  ) async {
    final confirmed = await _showDeleteConfirmation(context, controller);

    if (confirmed == true) {
      await _showLoadingDialog(context, controller);
    }
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    CleanupController controller,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Onay Gerekli'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu işlem geri alınamaz!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Silinecek kayıtlar:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('• Tarih aralığı: ${controller.getDateRangeText()}'),
            Text('• Hasta sayısı: ${controller.selectedPatientsCount}'),
            Text(
              '• Karar verilmemiş hastalar: ${controller.includeUndecided ? "Evet" : "Hayır"}',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tüm hasta fotoğrafları ve kayıtları kalıcı olarak silinecektir.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoadingDialog(
    BuildContext context,
    CleanupController controller,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              'Hastalar siliniyor...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Lütfen bekleyin',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );

    await _deletePatients(context, controller);

    if (context.mounted) {
      Navigator.of(context).pop();
      context.pop();
      ModernSnackBar.showSuccess(
        context,
        '${controller.selectedPatientsCount} hasta başarıyla silindi',
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _deletePatients(
    BuildContext context,
    CleanupController controller,
  ) async {
    try {
      final repository = context.read<ProfessorPatientRepository>();
      final patientIds = await controller.getPatientsToDelete();

      for (final patientId in patientIds) {
        try {
          await repository.deletePatient(patientId);
        } catch (e) {
          // Continue on error
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
