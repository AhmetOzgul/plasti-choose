import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/core/widgets/gradient_button.dart';
import 'package:plastinder/core/widgets/labeled_text_field.dart';
import 'package:plastinder/features/assistant/presentation/controllers/new_patient_controller.dart';

class NewPatientPage extends StatelessWidget {
  const NewPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

    return ChangeNotifierProvider<NewPatientController>(
      create: (_) => NewPatientController(),
      child: Builder(
        builder: (context) {
          final controller = context.watch<NewPatientController>();

          Future<void> pickImages() async {
            if (!controller.canAddMore()) return;
            final ImagePicker picker = ImagePicker();
            final List<XFile> files = await picker.pickMultiImage(
              imageQuality: 85,
            );
            for (final f in files) {
              if (!controller.canAddMore()) break;
              controller.addImage(File(f.path));
            }
          }

          Future<void> pickFromCamera() async {
            if (!controller.canAddMore()) return;
            final ImagePicker picker = ImagePicker();
            final XFile? f = await picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 85,
            );
            if (f != null) controller.addImage(File(f.path));
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Yeni Hasta')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                            onPressed: controller.canAddMore()
                                ? pickImages
                                : null,
                            child: const Text(
                              'Galeriden Seç',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            colors: [tertiary, secondary],
                            onPressed: controller.canAddMore()
                                ? pickFromCamera
                                : null,
                            child: const Text(
                              'Kamera',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Görseller (${controller.images.length}/10)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: controller.images.length,
                        onReorder: controller.reorder,
                        buildDefaultDragHandles: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final File file = controller.images[index];
                          return Dismissible(
                            key: ValueKey(file.path),
                            background: Container(
                              color: Colors.red.shade100,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Colors.red.shade600,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => controller.removeAt(index),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              clipBehavior: Clip.antiAlias,
                              child: SizedBox(
                                height: 120,
                                child: Row(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        file.path.split('/').last,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
                      colors: [secondary, tertiary],
                      onPressed: controller.hasMinimum() ? () {} : null,
                      child: const Text(
                        'Kaydet (Pasif)',
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
