import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plastinder/features/assistant/domain/repositories/patient_repository.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/core/widgets/modern_snackbar.dart';
import 'package:plastinder/features/assistant/presentation/widgets/patient_photos_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PatientListController extends ChangeNotifier {
  final PatientRepository _patientRepository;

  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  PatientListController(this._patientRepository) {
    _loadPatients();
  }

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patients = await _patientRepository.getAllPatients();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPatients() async {
    await _loadPatients();
  }

  Future<void> deletePatient(BuildContext context, Patient patient) async {
    BuildContext? dialogContext;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Delete images from Firebase Storage first
      await _deletePatientImages(patient);

      // Delete patient from Firestore
      await _patientRepository.deletePatient(patient.id);

      // Close loading dialog safely
      if (dialogContext != null && dialogContext!.mounted) {
        dialogContext!.pop();
      }

      // Show success message
      if (context.mounted) {
        ModernSnackBar.showSuccess(
          context,
          '${patient.displayName} başarıyla silindi!',
        );
      }

      // Refresh the patients list
      await _loadPatients();
    } catch (e) {
      // Close loading dialog safely
      if (dialogContext != null && dialogContext!.mounted) {
        dialogContext!.pop();
      }

      // Show error message
      if (context.mounted) {
        ModernSnackBar.showError(
          context,
          'Hasta silinirken hata oluştu: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _deletePatientImages(Patient patient) async {
    final storage = FirebaseStorage.instance;

    try {
      final imagesFolderPath = 'patients/${patient.id}/images';
      final folderRef = storage.ref(imagesFolderPath);

      // List all files in the folder
      final listResult = await folderRef.listAll();

      // Delete each file individually
      for (final fileRef in listResult.items) {
        await fileRef.delete();
      }
    } catch (e) {
      // Ignore storage deletion errors
    }
  }

  void showDeleteConfirmation(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Hastayı Sil'),
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
              '${patient.displayName} adlı hastanın tüm kayıtları silinecek.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Hasta bilgileri\n• Tüm fotoğraflar\n• Kayıt geçmişi',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop(); // Close dialog first
              await deletePatient(context, patient);
            },
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

  void showPatientPhotos(BuildContext context, Patient patient) {
    PatientPhotosDialog.show(context, patient);
  }
}
