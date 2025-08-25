import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:plastinder/features/auth/domain/entities/user.dart';
import 'package:plastinder/features/auth/domain/repositories/auth_repository.dart';

/// Provider controller for authentication.
final class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  AppUser? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppUser? get user => _user;

  AuthController(this._repository);

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.signIn(email: email, password: password);
      _user = user;
      _errorMessage = null;
    } on fb.FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          errorMsg = 'Şifre yanlış. Lütfen tekrar deneyin.';
          break;
        case 'invalid-email':
          errorMsg = 'Geçersiz e-posta adresi.';
          break;
        case 'user-disabled':
          errorMsg = 'Bu hesap devre dışı bırakılmış.';
          break;
        case 'too-many-requests':
          errorMsg = 'Çok fazla başarısız giriş denemesi. Lütfen bekleyin.';
          break;
        case 'network-request-failed':
          errorMsg =
              'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
          break;
        case 'invalid-credential':
          errorMsg = 'E-posta veya şifre yanlış.';
          break;
        default:
          errorMsg = 'Giriş yapılamadı: ${e.message ?? 'Bilinmeyen hata'}';
      }
      _errorMessage = errorMsg;
    } catch (e) {
      String errorMsg;
      if (e.toString().contains('User document not found')) {
        errorMsg =
            'Kullanıcı bilgileri bulunamadı. Lütfen yönetici ile iletişime geçin.';
      } else if (e.toString().contains('User role not found')) {
        errorMsg =
            'Kullanıcı rolü tanımlanmamış. Lütfen yönetici ile iletişime geçin.';
      } else {
        errorMsg = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
      }
      _errorMessage = errorMsg;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _repository.signOut();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Çıkış yapılamadı: ${e.toString()}';
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool isLoggedIn() => _user != null;
}
