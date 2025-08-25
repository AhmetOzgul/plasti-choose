import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:get_it/get_it.dart';
import 'package:plastinder/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:plastinder/features/auth/domain/repositories/auth_repository.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton<fb.FirebaseAuth>(fb.FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      getIt<fb.FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );
}
