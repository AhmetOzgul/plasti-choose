import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/core/widgets/gradient_button.dart';
import 'package:plastinder/core/widgets/labeled_text_field.dart';
import 'package:plastinder/core/widgets/error_banner.dart';
import 'package:plastinder/core/widgets/modern_snackbar.dart';
import 'package:plastinder/features/assistant/presentation/controllers/new_patient_controller.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:plastinder/features/assistant/domain/repositories/patient_repository.dart';

class NewPatientPage extends StatelessWidget {
  const NewPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

    return ChangeNotifierProvider<NewPatientController>(
      create: (_) => NewPatientController(context.read<PatientRepository>()),
      child: Builder(
        builder: (context) {
          final controller = context.watch<NewPatientController>();
          final authController = context.watch<AuthController>();

          Future<void> pickImages() async {
            if (!controller.canAddMore()) return;
            controller.setPickingImages(true);
            try {
              final ImagePicker picker = ImagePicker();
              final List<XFile> files = await picker.pickMultiImage(
                maxWidth: 1920,
                maxHeight: 1920,
                imageQuality: 85,
              );
              for (final f in files) {
                if (!controller.canAddMore()) break;
                controller.addImage(File(f.path));
              }
            } finally {
              controller.setPickingImages(false);
            }
          }

          Future<void> pickFromCamera() async {
            if (!controller.canAddMore()) return;
            controller.setPickingImages(true);
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? f = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
                maxWidth: 1920,
                maxHeight: 1920,
              );
              if (f != null) controller.addImage(File(f.path));
            } finally {
              controller.setPickingImages(false);
            }
          }

          Future<void> savePatient() async {
            final user = authController.user;
            if (user == null) {
              ModernSnackBar.showError(context, 'Kullanıcı bilgisi bulunamadı');
              return;
            }

            final success = await controller.savePatient(
              ownerProfessorId: user.ownerProfessorId ?? user.id,
              createdByAssistantId: user.id,
            );

            if (success) {
              Navigator.of(context).pop();
              ModernSnackBar.showSuccess(
                context,
                'Hasta başarıyla kaydedildi!',
              );
            }
          }

          void _showAnimatedImageDialog(
            BuildContext dialogContext,
            File imageFile,
          ) {
            showGeneralDialog(
              context: dialogContext,
              barrierDismissible: true,
              barrierLabel: '',
              barrierColor: Colors.black.withOpacity(0.8),
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(imageFile, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: FadeTransition(opacity: animation, child: child!),
                    );
                  },
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Yeni Hasta')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (controller.errorMessage != null)
                      ErrorBanner(
                        message: controller.errorMessage!,
                        onClose: controller.clearError,
                      ),
                    LabeledTextField(
                      controller: controller.nameController,
                      label: 'Ad Soyad',
                      hint: 'Hastanın adı',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            colors: [secondary, tertiary],
                            onPressed:
                                controller.canAddMore() &&
                                    !controller.isSubmitting &&
                                    !controller.isPickingImages
                                ? pickImages
                                : null,
                            child: controller.isPickingImages
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Galeriden Seç',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            colors: [tertiary, secondary],
                            onPressed:
                                controller.canAddMore() &&
                                    !controller.isSubmitting &&
                                    !controller.isPickingImages
                                ? pickFromCamera
                                : null,
                            child: controller.isPickingImages
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Kamera',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Görseller (${controller.images.length}/50)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                        itemCount: controller.images.length,
                        itemBuilder: (context, index) {
                          final File file = controller.images[index];
                          return Dismissible(
                            key: ValueKey(file.path),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => controller.removeAt(index),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showAnimatedImageDialog(
                                        context,
                                        file,
                                      ),
                                      child: FutureBuilder<Uint8List?>(
                                        future: controller.createThumbnail(
                                          file,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            );
                                          }
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    GradientButton(
                      colors:
                          controller.hasMinimum() && !controller.isSubmitting
                          ? [secondary, tertiary]
                          : [
                              secondary.withOpacity(0.3),
                              tertiary.withOpacity(0.3),
                            ],
                      onPressed:
                          controller.hasMinimum() && !controller.isSubmitting
                          ? savePatient
                          : null,
                      child: controller.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Kaydet',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
