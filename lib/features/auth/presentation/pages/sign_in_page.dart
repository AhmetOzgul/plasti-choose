import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';

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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              secondary.withOpacity(0.1),
              tertiary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48, // 48 = padding * 2
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo and Title
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [secondary, tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: secondary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PlasTinder',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plastik Cerrahi Asistanı',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Error Message
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade100.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              error,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            onPressed: () => authController.clearError(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200.withOpacity(0.8),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        hintText: 'ornek@email.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: secondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                      onChanged: (_) {
                        if (error != null) {
                          authController.clearError();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200.withOpacity(0.8),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: passCtrl,
                      obscureText: true,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        hintText: 'Şifrenizi girin',
                        prefixIcon: Icon(Icons.lock_outlined, color: secondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                      onChanged: (_) {
                        if (error != null) {
                          authController.clearError();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [secondary, tertiary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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
                  ),

                  const SizedBox(height: 60),

                  // Footer
                  Text(
                    '© 2024 Plastinder. Tüm hakları saklıdır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
