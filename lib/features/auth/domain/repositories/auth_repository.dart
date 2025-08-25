import 'package:plastinder/features/auth/domain/entities/user.dart';

/// Contract for authentication repository.
abstract interface class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  Stream<AppUser?> authStateChanges();
}
