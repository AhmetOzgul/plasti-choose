import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:plastinder/features/professor/presentation/controllers/review_deck_controller.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';
import 'package:plastinder/features/professor/presentation/widgets/modern_review_card.dart';

final class ReviewDeckPage extends StatelessWidget {
  const ReviewDeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReviewDeckController>(
      create: (context) {
        final authController = context.read<AuthController>();
        final professorId = authController.user?.id ?? '';
        final repository = context.read<ProfessorPatientRepository>();
        return ReviewDeckController(repository, professorId);
      },
      child: const _ReviewDeckPageContent(),
    );
  }
}

final class _ReviewDeckPageContent extends StatelessWidget {
  const _ReviewDeckPageContent();

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

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
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hasta İnceleme',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                    ),
                    const Spacer(),
                    Consumer<ReviewDeckController>(
                      builder: (context, controller, child) {
                        return Text(
                          '${controller.newPatients.length} hasta',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Consumer<ReviewDeckController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Hasta listesi yüklenirken hata oluştu',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.red.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.refresh(),
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (controller.newPatients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tüm hastalar incelendi!',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.green.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yeni hasta kayıtları geldiğinde burada görünecek',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.refresh(),
                              child: const Text('Yenile'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ModernReviewCard(
                      patient: controller.currentPatient!,
                      controller: controller,
                      secondary: secondary,
                      tertiary: tertiary,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
