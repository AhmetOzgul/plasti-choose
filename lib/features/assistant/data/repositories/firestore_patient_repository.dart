import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/features/assistant/data/utils/patient_utils.dart';
import 'package:plastinder/features/assistant/domain/repositories/patient_repository.dart';

final class FirestorePatientRepository implements PatientRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const FirestorePatientRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  @override
  Future<Patient> createPatient({
    required String displayName,
    required String ownerProfessorId,
    required String createdByAssistantId,
    required List<File> imageFiles,
  }) async {
    try {
      // 1. Generate patient ID
      final patientId = PatientIdGenerator.generateId();
      final now = DateTime.now();

      // 2. Create initial patient document
      final initialPatient = Patient(
        id: patientId,
        displayName: displayName,
        ownerProfessorId: ownerProfessorId,
        createdByAssistantId: createdByAssistantId,
        status: 'NEW',
        images: [],
        search: PatientSearchHelper.createSearchMetadata(displayName),
        createdAt: now,
        updatedAt: now,
      );

      // 3. Write to Firestore first
      await _firestore
          .collection('patients')
          .doc(patientId)
          .set(initialPatient.toMap());

      // 4. Upload images to Storage
      final uploadedImages = <PatientImage>[];
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final imageId = PatientIdGenerator.generateImageId();
        final fileName = '${imageId}_${i + 1}.jpg';
        final storagePath = 'patients/$patientId/images/$fileName';

        // Upload to Firebase Storage
        final storageRef = _storage.ref().child(storagePath);
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Get file metadata
        final metadata = await imageFile.stat();

        // Create PatientImage object
        final patientImage = PatientImage(
          id: imageId,
          url: downloadUrl,
          fileName: fileName,
          fileSize: metadata.size,
          contentType: 'image/jpeg',
          uploadedAt: now,
        );

        uploadedImages.add(patientImage);
      }

      // 5. Update Firestore with image metadata
      final updatedPatient = initialPatient.copyWith(
        images: uploadedImages,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('patients')
          .doc(patientId)
          .update(updatedPatient.toMap());

      return updatedPatient;
    } catch (e) {
      throw Exception('Failed to create patient: $e');
    }
  }

  @override
  Future<Patient?> getPatient(String patientId) async {
    try {
      final doc = await _firestore.collection('patients').doc(patientId).get();

      if (!doc.exists) return null;

      return Patient.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get patient: $e');
    }
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    try {
      final updatedData = patient.copyWith(updatedAt: DateTime.now()).toMap();

      await _firestore
          .collection('patients')
          .doc(patient.id)
          .update(updatedData);
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  @override
  Stream<List<Patient>> getPatientsForProfessor(String professorId) {
    return _firestore
        .collection('patients')
        .where('ownerProfessorId', isEqualTo: professorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Patient.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
