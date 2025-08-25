import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/app/router.dart';
import 'package:plastinder/app/theming/theme.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';

/// Root App widget using Provider and go_router.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final router = buildRouter(auth);

    return MaterialApp.router(
      title: 'Plastinder',
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
