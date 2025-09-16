import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/features/professor/presentation/controllers/professor_patient_list_controller.dart';
import 'package:plastinder/features/professor/presentation/widgets/professor_patient_card.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';

class ProfessorPatientListPage extends StatelessWidget {
  const ProfessorPatientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfessorPatientListController>(
      create: (_) {
        final repository = context.read<ProfessorPatientRepository>();
        final authController = context.read<AuthController>();
        return ProfessorPatientListController(repository, authController);
      },
      child: const _ProfessorPatientListPageContent(),
    );
  }
}

class _ProfessorPatientListPageContent extends StatelessWidget {
  const _ProfessorPatientListPageContent();

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
                      'Hasta Listesi',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                    ),
                    const Spacer(),
                    Consumer<ProfessorPatientListController>(
                      builder: (context, controller, child) {
                        return Text(
                          '${controller.patients.length} hasta',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<ProfessorPatientListController>(
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
                            ],
                          ),
                        );
                      }

                      if (controller.patients.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Henüz hasta kaydı bulunmuyor',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Yeni hasta eklemek için ana sayfadaki "Yeni Hasta" butonunu kullanın',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: controller.patients.length,
                        itemBuilder: (context, index) {
                          final patient = controller.patients[index];
                          return ProfessorPatientCard(
                            patient: patient,
                            secondary: secondary,
                            tertiary: tertiary,
                          );
                        },
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
