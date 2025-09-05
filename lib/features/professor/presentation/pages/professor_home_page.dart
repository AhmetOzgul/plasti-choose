import 'package:flutter/material.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/core/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class ProfessorHomePage extends StatelessWidget {
  const ProfessorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;
    final String displayName = context.select<AuthController, String>(
      (c) => c.user?.displayName ?? '',
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              secondary.withOpacity(0.05),
              tertiary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              CustomAppBar(
                secondary: secondary,
                tertiary: tertiary,
                displayName: displayName,
                context: context,
              ), // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doktor Paneli',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Access Cards
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildQuickAccessCard(
                              context,
                              icon: Icons.add_circle_outline,
                              title: 'Yeni Hasta',
                              subtitle: 'Hasta Oluştur',
                              color: tertiary,
                              onTap: () {
                                context.push('/professor/new');
                              },
                            ),
                            _buildQuickAccessCard(
                              context,
                              icon: Icons.people,
                              title: 'Hastalar',
                              subtitle: 'Hasta listesi',
                              color: secondary,
                              onTap: () => context.push('/professor/patients'),
                            ),
                            _buildQuickAccessCard(
                              context,
                              icon: Icons.medical_information,
                              title: 'Konsültasyon',
                              subtitle: 'Asistan desteği',
                              color: Colors.orange,
                              onTap: () {
                                // TODO: Navigate to consultation
                              },
                            ),
                            _buildQuickAccessCard(
                              context,
                              icon: Icons.analytics,
                              title: 'İstatistikler',
                              subtitle: 'Performans analizi',
                              color: Colors.purple,
                              onTap: () {
                                // TODO: Navigate to statistics
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
