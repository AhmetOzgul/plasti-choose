import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plastinder/features/assistant/domain/repositories/patient_repository.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/core/widgets/modern_snackbar.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PatientListController extends ChangeNotifier {
  final PatientRepository _patientRepository;

  PatientListController(this._patientRepository);

  Future<List<Patient>> getAllPatients() {
    return _patientRepository.getAllPatients();
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

      // Notify listeners to refresh the list
      notifyListeners();
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${patient.displayName} - Fotoğraflar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: patient.images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bu hastaya ait fotoğraf bulunmuyor',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: patient.images.length,
                        itemBuilder: (context, index) {
                          final imageUrl = patient.images[index].url;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
