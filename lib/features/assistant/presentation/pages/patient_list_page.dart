import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/features/assistant/presentation/controllers/patient_list_controller.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';

class PatientListPage extends StatelessWidget {
  const PatientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PatientListController>(
      create: (_) => PatientListController(context.read()),
      child: const _PatientListPageContent(),
    );
  }
}

class _PatientListPageContent extends StatefulWidget {
  const _PatientListPageContent();

  @override
  State<_PatientListPageContent> createState() =>
      _PatientListPageContentState();
}

class _PatientListPageContentState extends State<_PatientListPageContent> {
  late Future<List<Patient>> _patientsFuture;
  PatientListController? _controller;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _patientsFuture = Future.value(<Patient>[]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted && !_listenerAdded) {
      _controller = context.read<PatientListController>();
      _refreshPatients();

      // Listen to controller changes (only once)
      _controller!.addListener(_refreshPatients);
      _listenerAdded = true;
    }
  }

  void _refreshPatients() {
    if (mounted && _controller != null) {
      setState(() {
        _patientsFuture = _controller!.getAllPatients();
      });
    }
  }

  @override
  void dispose() {
    if (_listenerAdded && _controller != null) {
      _controller!.removeListener(_refreshPatients);
    }
    super.dispose();
  }

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
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FutureBuilder<List<Patient>>(
                          future: _patientsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.red.shade600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      snapshot.error.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final patients = snapshot.data ?? [];

                            if (patients.isEmpty) {
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Yeni hasta eklemek için ana sayfadaki "Yeni Hasta" butonunu kullanın',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: patients.length,
                              itemBuilder: (context, index) {
                                final patient = patients[index];
                                return _buildPatientCard(
                                  context,
                                  patient,
                                  secondary,
                                  tertiary,
                                );
                              },
                            );
                          },
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

  Widget _buildPatientCard(
    BuildContext context,
    Patient patient,
    Color secondary,
    Color tertiary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: secondary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: tertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.person, color: tertiary, size: 24),
        ),
        title: Text(
          patient.displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => context
                  .read<PatientListController>()
                  .showDeleteConfirmation(context, patient),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.shade400,
                size: 20,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
        onTap: () {
          context.read<PatientListController>().showPatientPhotos(
            context,
            patient,
          );
        },
      ),
    );
  }
}
