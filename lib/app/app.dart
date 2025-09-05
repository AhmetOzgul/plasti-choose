import 'package:flutter/material.dart';
import 'package:plastinder/app/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/app/router.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/core/widgets/splash_screen.dart';

/// Root App widget using Provider and go_router.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // Show splash screen while initializing
    if (auth.isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Plastinder',
        theme: buildAppTheme(),
        home: const SplashScreen(),
      );
    }

    final router = buildRouter(auth);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Plastinder',
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
