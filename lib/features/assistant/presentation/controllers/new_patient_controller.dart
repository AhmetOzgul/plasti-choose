import 'dart:io';
import 'package:flutter/material.dart';

class NewPatientController extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final List<File> _images = <File>[];
  bool _isSubmitting = false;

  List<File> get images => List.unmodifiable(_images);
  bool get isSubmitting => _isSubmitting;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  bool canAddMore() => _images.length < 10;
  bool hasMinimum() => nameController.text.trim().isNotEmpty;

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

  void removeAt(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final File item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    notifyListeners();
  }
}
