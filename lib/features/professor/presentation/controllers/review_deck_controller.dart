import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';

final class ReviewDeckController extends ChangeNotifier {
  final ProfessorPatientRepository _repository;
  final String _professorId;
  StreamSubscription<List<Patient>>? _streamSubscription;

  ReviewDeckController(this._repository, this._professorId) {
    _loadNewPatients();
  }

  List<Patient> _newPatients = [];
  bool _isLoading = false;
  String? _errorMessage;
  Patient? _currentPatient;

  List<Patient> get newPatients => _newPatients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Patient? get currentPatient => _currentPatient;
  bool get hasMorePatients => _newPatients.isNotEmpty;

  Stream<List<Patient>> get newPatientsStream =>
      _repository.getNewPatientsForProfessor(_professorId);

  void _loadNewPatients() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Önceki subscription'ı iptal et
      _streamSubscription?.cancel();

      // Stream'i dinle
      _streamSubscription = newPatientsStream.listen(
        (patients) {
          _newPatients = patients;
          _isLoading = false;
          _errorMessage = null;

          // İlk hastayı current olarak ayarla
          if (_currentPatient == null && patients.isNotEmpty) {
            _currentPatient = patients.first;
          }

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

  /// Sonraki hastaya geç
  void nextPatient() {
    if (_newPatients.isEmpty || _currentPatient == null) return;

    final currentIndex = _newPatients.indexOf(_currentPatient!);
    if (currentIndex < _newPatients.length - 1) {
      _currentPatient = _newPatients[currentIndex + 1];
      notifyListeners();
    }
  }

  /// Önceki hastaya geç
  void previousPatient() {
    if (_newPatients.isEmpty || _currentPatient == null) return;

    final currentIndex = _newPatients.indexOf(_currentPatient!);
    if (currentIndex > 0) {
      _currentPatient = _newPatients[currentIndex - 1];
      notifyListeners();
    }
  }

  /// Hastayı kabul et
  Future<void> acceptPatient(Patient patient) async {
    try {
      await _repository.updatePatientStatus(
        patient.id,
        'ACCEPTED',
        _professorId,
      );
      await _repository.removeReviewLock(patient.id);

      // Current patient'i hemen güncelle
      if (_currentPatient?.id == patient.id) {
        // Mevcut hastayı listeden kaldır
        _newPatients.removeWhere((p) => p.id == patient.id);

        // Sonraki hastayı seç
        if (_newPatients.isNotEmpty) {
          _currentPatient = _newPatients.first;
        } else {
          _currentPatient = null;
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Hasta kabul edilirken hata oluştu: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Hastayı reddet
  Future<void> rejectPatient(Patient patient) async {
    try {
      await _repository.updatePatientStatus(
        patient.id,
        'REJECTED',
        _professorId,
      );
      await _repository.removeReviewLock(patient.id);

      // Current patient'i hemen güncelle
      if (_currentPatient?.id == patient.id) {
        // Mevcut hastayı listeden kaldır
        _newPatients.removeWhere((p) => p.id == patient.id);

        // Sonraki hastayı seç
        if (_newPatients.isNotEmpty) {
          _currentPatient = _newPatients.first;
        } else {
          _currentPatient = null;
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Hasta reddedilirken hata oluştu: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Hastayı atla
  Future<void> skipPatient(Patient patient) async {
    try {
      await _repository.updatePatientStatus(
        patient.id,
        'SKIPPED',
        _professorId,
      );
      await _repository.removeReviewLock(patient.id);

      // Current patient'i hemen güncelle
      if (_currentPatient?.id == patient.id) {
        // Mevcut hastayı listeden kaldır
        _newPatients.removeWhere((p) => p.id == patient.id);

        // Sonraki hastayı seç
        if (_newPatients.isNotEmpty) {
          _currentPatient = _newPatients.first;
        } else {
          _currentPatient = null;
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Hasta atlanırken hata oluştu: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Hastayı inceleme moduna al (soft lock)
  Future<void> startReview(Patient patient) async {
    try {
      await _repository.createReviewLock(patient.id, _professorId, 30);
    } catch (e) {
      _errorMessage = 'İnceleme başlatılırken hata oluştu: ${e.toString()}';
      notifyListeners();
    }
  }

  /// İncelemeyi iptal et
  Future<void> cancelReview(Patient patient) async {
    try {
      await _repository.updatePatientStatus(patient.id, 'NEW', _professorId);
      await _repository.removeReviewLock(patient.id);
    } catch (e) {
      _errorMessage = 'İnceleme iptal edilirken hata oluştu: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Listeyi yenile
  void refresh() {
    _loadNewPatients();
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
