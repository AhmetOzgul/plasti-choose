import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plastinder/features/auth/data/models/app_user_model.dart';
import 'package:plastinder/features/auth/domain/entities/user.dart';
import 'package:plastinder/features/auth/domain/repositories/user_repository.dart';

/// Firestore-backed UserRepository implementation.
final class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  FirestoreUserRepository(this._firestore);

  CollectionReference<Map<String, Object?>> get _col =>
      _firestore.collection('users');

  @override
  Future<AppUser?> getById(String userId) async {
    final snap = await _col.doc(userId).get();
    final data = snap.data();
    if (data == null) return null;
    return AppUserModel.fromMap(snap.id, data).toEntity();
  }

  @override
  Future<void> upsert(AppUser user) async {
    final model = AppUserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
    );
    await _col
        .doc(user.id)
        .set(model.toMap(forUpdate: false), SetOptions(merge: true));
  }
}
