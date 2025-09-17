import 'package:plastinder/features/assistant/data/models/patient_model.dart';

abstract interface class ProfessorPatientRepository {
  /// Profesöre ait status=NEW olan hastaları FIFO sırasında getirir
  Stream<List<Patient>> getNewPatientsForProfessor(String professorId);

  /// Profesöre ait belirli durumdaki hastaları getirir
  Stream<List<Patient>> getPatientsByStatusForProfessor(
    String professorId,
    String status,
  );

  /// Profesöre ait tüm hastaları getirir (filtreleme için)
  Stream<List<Patient>> getAllPatientsForProfessor(String professorId);

  /// Hasta durumunu günceller (review için)
  Future<void> updatePatientStatus(
    String patientId,
    String status,
    String decidedBy,
  );

  /// Review lock oluşturur
  Future<void> createReviewLock(
    String patientId,
    String lockedBy,
    int ttlSeconds,
  );

  /// Review lock'u kaldırır
  Future<void> removeReviewLock(String patientId);

  /// Hastayı siler (temizlik için)
  Future<void> deletePatient(String patientId);

  /// Belirli tarih aralığındaki hasta sayısını getirir (temizlik için)
  Future<int> getPatientCountByDateRange(
    String professorId,
    DateTime startDate,
    DateTime endDate,
    bool includeUndecided,
  );
}
