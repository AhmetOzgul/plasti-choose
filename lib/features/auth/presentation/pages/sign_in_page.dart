import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/core/widgets/error_banner.dart';
import 'package:plastinder/core/widgets/labeled_text_field.dart';
import 'package:plastinder/core/widgets/gradient_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final TextEditingController emailCtrl;
  late final TextEditingController passCtrl;

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController();
    passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;
    final authController = context.watch<AuthController>();
    final bool loading = authController.isLoading;
    final String? error = authController.errorMessage;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0.35, 0.7, 0.9],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              secondary.withOpacity(0.1),
              tertiary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Builder(
                    builder: (context) {
                      final media = MediaQuery.of(context);
                      final double viewportHeight =
                          media.size.height -
                          media.padding.top -
                          media.padding.bottom -
                          48;
                      final double topGap = (viewportHeight * 0.08).clamp(
                        24.0,
                        96.0,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: topGap),
                          Image.asset('assets/images/logo.png'),
                          const SizedBox(height: 24),
                          const Spacer(flex: 2),

                          // Error Message
                          if (error != null) ...[
                            ErrorBanner(
                              message: error,
                              onClose: authController.clearError,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Email Field
                          LabeledTextField(
                            controller: emailCtrl,
                            label: 'E-posta',
                            hint: 'ornek@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            onClearError: error != null
                                ? authController.clearError
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          LabeledTextField(
                            controller: passCtrl,
                            label: 'Şifre',
                            hint: 'Şifrenizi girin',
                            icon: Icons.lock_outlined,
                            obscureText: true,
                            onClearError: error != null
                                ? authController.clearError
                                : null,
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          GradientButton(
                            colors: [secondary, tertiary],
                            onPressed: loading
                                ? null
                                : () async {
                                    await authController.login(
                                      emailCtrl.text.trim(),
                                      passCtrl.text,
                                    );
                                    if (!mounted) return;
                                    final user = authController.user;
                                    if (user != null) {
                                      if (user.isProfessor()) {
                                        context.go('/professor/home');
                                      } else if (user.isAssistant()) {
                                        context.go('/assistant/home');
                                      }
                                    }
                                  },
                            child: loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const Spacer(flex: 1),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              '© 2025 Plastinder. Tüm hakları saklıdır.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
