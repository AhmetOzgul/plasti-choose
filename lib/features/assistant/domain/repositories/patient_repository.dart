import 'dart:io';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';

abstract interface class PatientRepository {
  /// Creates a new patient record with images
  Future<Patient> createPatient({
    required String displayName,
    required String ownerProfessorId,
    required String createdByAssistantId,
    required List<File> imageFiles,
  });

  /// Gets a patient by ID
  Future<Patient?> getPatient(String patientId);

  /// Updates a patient
  Future<void> updatePatient(Patient patient);

  /// Stream of patients for a professor
  Stream<List<Patient>> getPatientsForProfessor(String professorId);
}
