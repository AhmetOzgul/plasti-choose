import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:plastinder/features/auth/domain/entities/user.dart';
import 'package:plastinder/features/auth/domain/repositories/auth_repository.dart';

/// Firebase-backed implementation of AuthRepository.
final class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository(this._auth, this._firestore);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final mail = cred.user!.email ?? email;
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) {
      throw Exception('User document not found');
    }
    final displayName = (data['displayName'] as String?) ?? '';
    final role = data['role'] as String?;
    if (role == null) {
      throw Exception('User role not found');
    }
    return AppUser(id: uid, email: mail, role: role, displayName: displayName);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fb.User? u) async {
      if (u == null) return null;
      final snap = await _firestore.collection('users').doc(u.uid).get();
      final data = snap.data();
      if (data == null) return null;
      final role = data['role'] as String?;
      if (role == null) return null;
      final displayName = (data['displayName'] as String?) ?? '';
      return AppUser(
        id: u.uid,
        email: u.email ?? '',
        role: role,
        displayName: displayName,
      );
    });
  }
}
