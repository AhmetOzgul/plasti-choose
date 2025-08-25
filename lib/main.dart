import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plastinder/app/di.dart';
import 'package:plastinder/app/app.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plastinder/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

/// Entry point of the Plastinder Flutter application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    await fb.FirebaseAuth.instance.signOut();
  }
  configureDependencies();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => getIt<AuthRepository>()),
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(ctx.read<AuthRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
