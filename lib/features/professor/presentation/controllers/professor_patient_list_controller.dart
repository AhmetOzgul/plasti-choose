import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/core/widgets/modern_snackbar.dart';
import 'package:plastinder/features/assistant/presentation/widgets/patient_photos_dialog.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';

class ProfessorPatientListController extends ChangeNotifier {
  final ProfessorPatientRepository _repository;
  final AuthController _authController;

  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Patient>>? _streamSubscription;

  ProfessorPatientListController(this._repository, this._authController) {
    _loadPatients();
  }

  String get _professorId => _authController.user?.id ?? '';

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Önceki subscription'ı iptal et
      _streamSubscription?.cancel();

      _streamSubscription = _repository
          .getAllPatientsForProfessor(_professorId)
          .listen(
            (patients) {
              _patients = patients;
              _isLoading = false;
              _errorMessage = null;
              notifyListeners();
            },
            onError: (error) {
              _errorMessage = error.toString();
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPatients() async {
    await _loadPatients();
  }

  Future<void> changePatientStatus(
    BuildContext context,
    Patient patient,
    String newStatus,
  ) async {
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

      // Update patient status
      await _repository.updatePatientStatus(
        patient.id,
        newStatus,
        _professorId,
      );

      // Close loading dialog safely
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }

      // Show success message
      if (context.mounted) {
        ModernSnackBar.showSuccess(
          context,
          '${patient.displayName} durumu güncellendi',
        );
      }

      // Refresh the patients list
      await _loadPatients();
    } catch (e) {
      // Close loading dialog safely
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }

      // Show error message
      if (context.mounted) {
        ModernSnackBar.showError(
          context,
          'Durum güncellenirken hata oluştu: ${e.toString()}',
        );
      }
    }
  }

  void showStatusChangeDialog(BuildContext context, Patient patient) {
    String selectedStatus = patient.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit_rounded, color: Colors.blue.shade600, size: 28),
              const SizedBox(width: 12),
              const Text('Durumu Değiştir'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${patient.displayName} için yeni durum seçin:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Mevcut durum gösterimi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(patient.status),
                      color: _getStatusColor(patient.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mevcut: ${_getStatusText(patient.status)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(patient.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: _getStatusOptions().map((status) {
                      return DropdownMenuItem<String>(
                        value: status['value'],
                        child: Row(
                          children: [
                            Icon(
                              status['icon'],
                              color: status['color'],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status['text'],
                              style: TextStyle(
                                color: status['color'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'İptal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: selectedStatus != patient.status
                  ? () async {
                      Navigator.of(context).pop(); // Close dialog first
                      await changePatientStatus(
                        context,
                        patient,
                        selectedStatus,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  void showPatientPhotos(BuildContext context, Patient patient) {
    PatientPhotosDialog.show(context, patient);
  }

  List<Map<String, dynamic>> _getStatusOptions() {
    return [
      {
        'value': 'NEW',
        'text': 'Yeni',
        'icon': Icons.fiber_new,
        'color': Colors.blue.shade600,
      },
      {
        'value': 'IN_REVIEW',
        'text': 'İnceleniyor',
        'icon': Icons.visibility,
        'color': Colors.orange.shade600,
      },
      {
        'value': 'ACCEPTED',
        'text': 'Kabul Edildi',
        'icon': Icons.check_circle,
        'color': Colors.green.shade600,
      },
      {
        'value': 'REJECTED',
        'text': 'Reddedildi',
        'icon': Icons.cancel,
        'color': Colors.red.shade600,
      },
      {
        'value': 'SKIPPED',
        'text': 'Atlandı',
        'icon': Icons.skip_next,
        'color': Colors.grey.shade600,
      },
    ];
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'NEW':
        return Icons.fiber_new;
      case 'IN_REVIEW':
        return Icons.visibility;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'SKIPPED':
        return Icons.skip_next;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return Colors.blue.shade600;
      case 'IN_REVIEW':
        return Colors.orange.shade600;
      case 'ACCEPTED':
        return Colors.green.shade600;
      case 'REJECTED':
        return Colors.red.shade600;
      case 'SKIPPED':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'NEW':
        return 'Yeni';
      case 'IN_REVIEW':
        return 'İnceleniyor';
      case 'ACCEPTED':
        return 'Kabul Edildi';
      case 'REJECTED':
        return 'Reddedildi';
      case 'SKIPPED':
        return 'Atlandı';
      default:
        return 'Bilinmiyor';
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
