import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Patient fotoğrafları için özel cache manager
final class PatientImageCacheManager extends CacheManager {
  static const key = 'patientImagesCache';

  static PatientImageCacheManager? _instance;

  factory PatientImageCacheManager() {
    _instance ??= PatientImageCacheManager._();
    return _instance!;
  }

  PatientImageCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 7), // 7 gün cache'de kalır
          maxNrOfCacheObjects: 200, // Maksimum 200 resim cache'de
          repo: JsonCacheInfoRepository(databaseName: key),
          fileService: HttpFileService(),
        ),
      );
}
