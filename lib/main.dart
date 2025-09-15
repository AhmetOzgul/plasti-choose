import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastinder/app/di.dart';
import 'package:plastinder/app/app.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/features/auth/domain/repositories/auth_repository.dart';
import 'package:plastinder/features/assistant/domain/repositories/patient_repository.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plastinder/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => getIt<AuthRepository>()),
        Provider<PatientRepository>(create: (_) => getIt<PatientRepository>()),
        Provider<ProfessorPatientRepository>(
          create: (_) => getIt<ProfessorPatientRepository>(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(ctx.read<AuthRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
