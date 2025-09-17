import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';

final class ProfessorPatientRepositoryImpl
    implements ProfessorPatientRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const ProfessorPatientRepositoryImpl(this._firestore, this._storage);

  @override
  Stream<List<Patient>> getNewPatientsForProfessor(String professorId) {
    return _firestore
        .collection('patients')
        .where('ownerProfessorId', isEqualTo: professorId)
        .where(
          'status',
          whereIn: ['NEW', 'SKIPPED'],
        ) // NEW ve SKIPPED hastaları getir
        .snapshots()
        .map((snapshot) {
          final patients = snapshot.docs
              .map((doc) => Patient.fromMap(doc.data(), doc.id))
              .toList();
          // Client-side FIFO sıralama
          patients.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return patients;
        });
  }

  @override
  Stream<List<Patient>> getPatientsByStatusForProfessor(
    String professorId,
    String status,
  ) {
    return _firestore
        .collection('patients')
        .where('ownerProfessorId', isEqualTo: professorId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Patient.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<Patient>> getAllPatientsForProfessor(String professorId) {
    return _firestore
        .collection('patients')
        .where('ownerProfessorId', isEqualTo: professorId)
        .snapshots()
        .map((snapshot) {
          final patients = snapshot.docs
              .map((doc) => Patient.fromMap(doc.data(), doc.id))
              .toList();
          // Client-side sıralama
          patients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return patients;
        });
  }

  @override
  Future<void> updatePatientStatus(
    String patientId,
    String status,
    String decidedBy,
  ) async {
    await _firestore.collection('patients').doc(patientId).update({
      'status': status,
      'decision': {
        'decidedBy': decidedBy,
        'decidedAt': Timestamp.now(),
        'status': status,
      },
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> createReviewLock(
    String patientId,
    String lockedBy,
    int ttlSeconds,
  ) async {
    await _firestore.collection('patients').doc(patientId).update({
      'status': 'IN_REVIEW',
      'reviewLock': {
        'lockedBy': lockedBy,
        'lockedAt': Timestamp.now(),
        'ttlSeconds': ttlSeconds,
      },
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> removeReviewLock(String patientId) async {
    await _firestore.collection('patients').doc(patientId).update({
      'reviewLock': FieldValue.delete(),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> deletePatient(String patientId) async {
    try {
      // Önce hastayı getir
      final patientDoc = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (patientDoc.exists) {
        final patientData = patientDoc.data()!;
        final patient = Patient.fromMap(patientData, patientId);

        // Fotoğrafları klasör olarak sil
        try {
          final imagesFolderPath = 'patients/${patient.id}/images';
          final folderRef = _storage.ref(imagesFolderPath);

          // Klasördeki tüm dosyaları listele ve sil
          final listResult = await folderRef.listAll();
          for (final fileRef in listResult.items) {
            await fileRef.delete();
          }
        } catch (e) {
          // Fotoğraf silme hatası, devam et
        }

        // Firestore'dan hastayı sil
        await _firestore.collection('patients').doc(patientId).delete();
        print('ProfessorPatientRepository: Hasta silindi: $patientId');
      }
    } catch (e) {
      print('ProfessorPatientRepository: Hasta silinirken hata: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPatientCountByDateRange(
    String professorId,
    DateTime startDate,
    DateTime endDate,
    bool includeUndecided,
  ) async {
    Query query = _firestore
        .collection('patients')
        .where('ownerProfessorId', isEqualTo: professorId)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

    if (!includeUndecided) {
      // Sadece kabul/red edilen hastalar
      query = query.where('status', whereIn: ['ACCEPTED', 'REJECTED']);
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }
}
