import 'package:flutter/material.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';

final class CleanupController extends ChangeNotifier {
  final ProfessorPatientRepository _repository;
  final AuthController _authController;

  CleanupController(this._repository, this._authController);

  String get _professorId => _authController.user?.id ?? '';

  // State
  Duration? _selectedDuration;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeUndecided = false;
  int _selectedPatientsCount = 0;
  bool _isAllSelected = false;

  // Getters
  Duration? get selectedDuration => _selectedDuration;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get includeUndecided => _includeUndecided;
  int get selectedPatientsCount => _selectedPatientsCount;
  bool get isAllSelected => _isAllSelected;

  bool get canDelete {
    return _selectedDuration != null ||
        (_startDate != null && _endDate != null) ||
        _isAllSelected;
  }

  void selectDuration(Duration? duration) {
    _selectedDuration = duration;
    _startDate = null;
    _endDate = null;
    _isAllSelected = (duration == null);
    _updatePatientCount();
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    _selectedDuration = null;
    _isAllSelected = false;
    _updatePatientCount();
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    _selectedDuration = null;
    _isAllSelected = false;
    _updatePatientCount();
    notifyListeners();
  }

  void setIncludeUndecided(bool value) {
    _includeUndecided = value;
    _updatePatientCount();
    notifyListeners();
  }

  void _updatePatientCount() {
    if (_selectedDuration != null ||
        (_startDate != null && _endDate != null) ||
        _isAllSelected) {
      _calculateRealPatientCount();
    } else {
      _selectedPatientsCount = 0;
      notifyListeners();
    }
  }

  void _calculateRealPatientCount() async {
    try {
      final dateRange = _calculateDateRange();
      final count = await _getRealPatientCount(dateRange.start, dateRange.end);
      _selectedPatientsCount = count;
      notifyListeners();
    } catch (e) {
      _selectedPatientsCount = 0;
      notifyListeners();
    }
  }

  Future<int> _getRealPatientCount(DateTime start, DateTime end) async {
    try {
      final allPatients = await _repository
          .getAllPatientsForProfessor(_professorId)
          .first;

      final patientsToDelete = allPatients.where((patient) {
        final isInDateRange =
            patient.createdAt.isAfter(start) && patient.createdAt.isBefore(end);
        final shouldInclude =
            _includeUndecided ||
            (patient.status == 'ACCEPTED' || patient.status == 'REJECTED');
        return isInDateRange && shouldInclude;
      }).toList();

      return patientsToDelete.length;
    } catch (e) {
      return 0;
    }
  }

  ({DateTime start, DateTime end}) _calculateDateRange() {
    if (_selectedDuration != null) {
      return (
        start: DateTime(2020),
        end: DateTime.now().subtract(_selectedDuration!),
      );
    } else if (_startDate != null && _endDate != null) {
      return (start: _startDate!, end: _endDate!);
    } else {
      return (
        start: DateTime(2020),
        end: DateTime.now().add(Duration(days: 1)),
      );
    }
  }

  String getDateRangeText() {
    if (_selectedDuration != null) {
      final days = _selectedDuration!.inDays;
      if (days <= 7) return '1 haftadan eski kayıtlar';
      if (days <= 30) return '1 aydan eski kayıtlar';
      if (days <= 90) return '3 aydan eski kayıtlar';
      if (days <= 180) return '6 aydan eski kayıtlar';
      return '1 yıldan eski kayıtlar';
    } else if (_startDate != null && _endDate != null) {
      return '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    } else if (_selectedDuration == null &&
        _startDate == null &&
        _endDate == null) {
      return 'Tüm hastalar';
    }
    return 'Belirtilmemiş';
  }

  Future<List<String>> getPatientsToDelete() async {
    try {
      final dateRange = _calculateDateRange();
      final allPatients = await _repository
          .getAllPatientsForProfessor(_professorId)
          .first;

      final patientsToDelete = allPatients.where((patient) {
        final isInDateRange =
            patient.createdAt.isAfter(dateRange.start) &&
            patient.createdAt.isBefore(dateRange.end);
        final shouldInclude =
            _includeUndecided ||
            (patient.status == 'ACCEPTED' || patient.status == 'REJECTED');
        return isInDateRange && shouldInclude;
      }).toList();

      return patientsToDelete.map((patient) => patient.id).toList();
    } catch (e) {
      return [];
    }
  }
}
