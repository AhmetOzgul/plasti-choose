import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/features/auth/presentation/pages/sign_in_page.dart';
import 'package:plastinder/features/assistant/presentation/pages/assistant_home_page.dart';
import 'package:plastinder/features/professor/presentation/pages/professor_home_page.dart';

GoRouter buildRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/signin',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn();
      final loggingIn = state.matchedLocation == '/signin';

      if (!loggedIn && !loggingIn) return '/signin';
      if (loggedIn && loggingIn) {
        return auth.user!.isProfessor() ? '/professor/home' : '/assistant/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/signin', builder: (context, state) => const SignInPage()),
      GoRoute(
        path: '/assistant/home',
        builder: (context, state) => const AssistantHomePage(),
      ),
      GoRoute(
        path: '/professor/home',
        builder: (context, state) => const ProfessorHomePage(),
      ),
    ],
  );
}
