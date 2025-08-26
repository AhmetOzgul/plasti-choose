import 'package:plastinder/features/auth/domain/entities/user.dart';

/// Contract for user repository operations on Firestore.
abstract interface class UserRepository {
  Future<AppUser?> getById(String userId);
  Future<void> upsert(AppUser user);
}
