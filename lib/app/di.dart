import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:plastinder/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:plastinder/features/auth/domain/repositories/auth_repository.dart';
import 'package:plastinder/features/auth/data/repositories/firestore_user_repository.dart';
import 'package:plastinder/features/auth/domain/repositories/user_repository.dart';
import 'package:plastinder/features/assistant/data/repositories/firestore_patient_repository.dart';
import 'package:plastinder/features/assistant/domain/repositories/patient_repository.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton<fb.FirebaseAuth>(fb.FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      getIt<fb.FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => FirestoreUserRepository(getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<PatientRepository>(
    () => FirestorePatientRepository(
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );
}
