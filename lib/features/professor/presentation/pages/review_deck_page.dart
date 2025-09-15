import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:plastinder/features/professor/presentation/controllers/review_deck_controller.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/features/professor/domain/repositories/professor_patient_repository.dart';

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

                    return _ReviewCard(
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

final class _ReviewCard extends StatefulWidget {
  final Patient patient;
  final ReviewDeckController controller;
  final Color secondary;
  final Color tertiary;

  const _ReviewCard({
    required this.patient,
    required this.controller,
    required this.secondary,
    required this.tertiary,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

final class _ReviewCardState extends State<_ReviewCard> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Patient Info Card
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.secondary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Patient Name
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      widget.patient.displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Images Gallery
                  Expanded(
                    child: widget.patient.images.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bu hastaya ait fotoğraf bulunmuyor',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: widget.patient.images.length,
                            itemBuilder: (context, index) {
                              final image = widget.patient.images[index];
                              return Container(
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    image.url,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: widget.tertiary.withOpacity(
                                              0.1,
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(widget.tertiary),
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: widget.tertiary.withOpacity(0.1),
                                        child: Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Image Counter
                  if (widget.patient.images.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${widget.patient.images.length} fotoğraf',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Expanded(
            flex: 1,
            child: Row(
              children: [
                // Reject Button
                Expanded(
                  child: _ActionButton(
                    icon: Icons.close,
                    label: 'Reddet',
                    color: Colors.red,
                    onTap: () =>
                        widget.controller.rejectPatient(widget.patient),
                  ),
                ),
                const SizedBox(width: 16),

                // Skip Button
                Expanded(
                  child: _ActionButton(
                    icon: Icons.skip_next,
                    label: 'Atla',
                    color: Colors.orange,
                    onTap: () => widget.controller.skipPatient(widget.patient),
                  ),
                ),
                const SizedBox(width: 16),

                // Accept Button
                Expanded(
                  child: _ActionButton(
                    icon: Icons.check,
                    label: 'Kabul Et',
                    color: Colors.green,
                    onTap: () =>
                        widget.controller.acceptPatient(widget.patient),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
