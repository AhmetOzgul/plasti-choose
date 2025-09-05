import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/features/assistant/domain/repositories/patient_repository.dart';

class NewPatientController extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final List<File> _images = <File>[];
  final Map<String, Uint8List> _thumbnailCache = <String, Uint8List>{};
  bool _isSubmitting = false;
  bool _isPickingImages = false;
  String? _errorMessage;
  Patient? _createdPatient;

  final PatientRepository _patientRepository;

  NewPatientController(this._patientRepository);

  List<File> get images => List.unmodifiable(_images);
  bool get isSubmitting => _isSubmitting;
  bool get isPickingImages => _isPickingImages;
  String? get errorMessage => _errorMessage;
  Patient? get createdPatient => _createdPatient;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  bool canAddMore() => _images.length < 50;
  bool hasMinimum() =>
      nameController.text.trim().isNotEmpty && _images.isNotEmpty;

  void setSubmitting(bool value) {
    if (_isSubmitting == value) return;
    _isSubmitting = value;
    notifyListeners();
  }

  void setName(String value) {
    nameController.text = value;
    notifyListeners();
  }

  void addImage(File file) {
    if (!canAddMore()) return;
    _images.add(file);
    notifyListeners();
  }

  void setPickingImages(bool value) {
    if (_isPickingImages == value) return;
    _isPickingImages = value;
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _images.length) return;
    final file = _images[index];
    _images.removeAt(index);
    _thumbnailCache.remove(file.path); // Cache'den de kaldır
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final File item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    notifyListeners();
  }

  void clearImages() {
    _images.clear();
    _thumbnailCache.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<Uint8List?> createThumbnail(File imageFile) async {
    final String cacheKey = imageFile.path;

    // Cache'den kontrol et
    if (_thumbnailCache.containsKey(cacheKey)) {
      return _thumbnailCache[cacheKey];
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await instantiateImageCodec(
        bytes,
        targetWidth: 200,
        targetHeight: 200,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ImageByteFormat.png,
      );

      final thumbnail = byteData?.buffer.asUint8List();
      if (thumbnail != null) {
        _thumbnailCache[cacheKey] = thumbnail;
      }

      return thumbnail;
    } catch (e) {
      print('Thumbnail oluşturma hatası: $e');
      return null;
    }
  }

  Future<bool> savePatient({
    required String ownerProfessorId,
    required String createdByAssistantId,
  }) async {
    if (!hasMinimum()) {
      _errorMessage = 'Lütfen hasta adını girin ve en az bir görsel seçin.';
      notifyListeners();
      return false;
    }

    setSubmitting(true);
    clearError();

    try {
      final patient = await _patientRepository.createPatient(
        displayName: nameController.text.trim(),
        ownerProfessorId: ownerProfessorId,
        createdByAssistantId: createdByAssistantId,
        imageFiles: _images,
      );

      _createdPatient = patient;

      // Clear form
      nameController.clear();
      _images.clear();

      setSubmitting(false);
      return true;
    } catch (e) {
      _errorMessage = 'Hasta kaydı oluşturulamadı: $e';
      setSubmitting(false);
      return false;
    }
  }
}
