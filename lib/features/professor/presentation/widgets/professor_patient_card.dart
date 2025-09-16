import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/features/professor/presentation/controllers/professor_patient_list_controller.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/core/cache/image_cache_manager.dart';

final class ProfessorPatientCard extends StatelessWidget {
  final Patient patient;
  final Color secondary;
  final Color tertiary;

  const ProfessorPatientCard({
    super.key,
    required this.patient,
    required this.secondary,
    required this.tertiary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: secondary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<ProfessorPatientListController>().showPatientPhotos(
              context,
              patient,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Hasta fotoğrafı veya avatar
                _PatientAvatar(patient: patient, tertiary: tertiary),
                const SizedBox(width: 16),

                // Hasta bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.displayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      _PatientStatusChip(status: patient.status),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${patient.images.length} fotoğraf',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(patient.createdAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Aksiyon butonları
                Column(
                  children: [
                    // Durum değiştirme butonu
                    IconButton(
                      onPressed: () => context
                          .read<ProfessorPatientListController>()
                          .showStatusChangeDialog(context, patient),
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.blue.shade400,
                        size: 20,
                      ),
                      tooltip: 'Durumu Değiştir',
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}

final class _PatientAvatar extends StatelessWidget {
  final Patient patient;
  final Color tertiary;

  const _PatientAvatar({required this.patient, required this.tertiary});

  @override
  Widget build(BuildContext context) {
    if (patient.images.isNotEmpty) {
      // 2 veya daha fazla fotoğraf varsa 2. fotoğrafı, yoksa ilk fotoğrafı göster
      final imageIndex = patient.images.length >= 2 ? 1 : 0;
      final imageUrl = patient.images[imageIndex].url;

      return Container(
        width: 60,
        height: 60,
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
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            cacheManager: PatientImageCacheManager(),
            placeholder: (context, url) => Container(
              color: tertiary.withOpacity(0.1),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(tertiary),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: tertiary.withOpacity(0.1),
              child: Icon(Icons.person, color: tertiary, size: 24),
            ),
          ),
        ),
      );
    } else {
      // Fotoğraf yoksa varsayılan avatar göster
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: tertiary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tertiary.withOpacity(0.2), width: 1),
        ),
        child: Icon(Icons.person, color: tertiary, size: 28),
      );
    }
  }
}

final class _PatientStatusChip extends StatelessWidget {
  final String status;

  const _PatientStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'NEW':
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        statusText = 'Yeni';
        statusIcon = Icons.fiber_new;
        break;
      case 'IN_REVIEW':
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        statusText = 'İnceleniyor';
        statusIcon = Icons.visibility;
        break;
      case 'ACCEPTED':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        statusText = 'Kabul Edildi';
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        statusText = 'Reddedildi';
        statusIcon = Icons.cancel;
        break;
      case 'SKIPPED':
        chipColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        statusText = 'Atlandı';
        statusIcon = Icons.skip_next;
        break;
      default:
        chipColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        statusText = 'Bilinmiyor';
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
