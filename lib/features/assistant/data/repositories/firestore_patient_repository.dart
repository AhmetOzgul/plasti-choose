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
    String? patientId;
    try {
      // 1. Generate patient ID
      patientId = PatientIdGenerator.generateId();
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

      // 4. Upload images to Storage with error handling
      final uploadedImages = <PatientImage>[];
      for (int i = 0; i < imageFiles.length; i++) {
        try {
          final imageFile = imageFiles[i];

          // Check if file exists
          if (!await imageFile.exists()) {
            continue;
          }

          // Check file size (max 10MB)
          final metadata = await imageFile.stat();
          if (metadata.size > 10 * 1024 * 1024) {
            continue;
          }

          // Check file size (min 1KB)
          if (metadata.size < 1024) {
            continue;
          }

          final imageId = PatientIdGenerator.generateImageId();
          final fileName = '${imageId}_${i + 1}.jpg';
          final storagePath = 'patients/$patientId/images/$fileName';

          // Upload to Firebase Storage with timeout
          final storageRef = _storage.ref().child(storagePath);
          final uploadTask = storageRef.putFile(imageFile);

          // Wait for upload with timeout
          final snapshot = await uploadTask.timeout(
            const Duration(minutes: 3), // 3 dakika timeout
            onTimeout: () {
              throw Exception('Resim yükleme zaman aşımına uğradı');
            },
          );

          final downloadUrl = await snapshot.ref.getDownloadURL();

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
        } catch (e) {
          // If image upload fails, continue with other images
          // Don't throw here, continue with other images
        }
      }

      // En az bir resim yüklenmiş olmalı
      if (uploadedImages.isEmpty) {
        throw Exception('Hiçbir resim yüklenemedi. Lütfen tekrar deneyin.');
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
      // Cleanup: Delete patient document if it was created
      if (patientId != null) {
        try {
          await _firestore.collection('patients').doc(patientId).delete();
        } catch (cleanupError) {
          // Ignore cleanup errors
        }
      }

      // Daha detaylı hata mesajı
      String errorMessage = 'Hasta oluşturulamadı';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Yetki hatası. Lütfen tekrar giriş yapın.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'İnternet bağlantı sorunu. Lütfen tekrar deneyin.';
      } else if (e.toString().contains('quota')) {
        errorMessage =
            'Depolama kotası aşıldı. Lütfen daha sonra tekrar deneyin.';
      } else if (e.toString().contains('unavailable')) {
        errorMessage =
            'Servis geçici olarak kullanılamıyor. Lütfen tekrar deneyin.';
      } else {
        errorMessage = 'Hasta oluşturulamadı: ${e.toString()}';
      }

      throw Exception(errorMessage);
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

  @override
  Future<List<Patient>> getAllPatients() async {
    try {
      final snapshot = await _firestore
          .collection('patients')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Patient.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Hasta listesi alınamadı: $e');
    }
  }

  @override
  Future<void> deletePatient(String patientId) async {
    try {
      await _firestore.collection('patients').doc(patientId).delete();
    } catch (e) {
      throw Exception('Hasta silinemedi: $e');
    }
  }
}
