import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plastinder/features/auth/domain/entities/user.dart';

/// Firestore DTO for application user.
final class AppUserModel {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'assistant' | 'professor'
  final String? ownerProfessorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.ownerProfessorId,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUserModel.fromMap(String id, Map<String, Object?> data) {
    final Timestamp? cAt = data['createdAt'] as Timestamp?;
    final Timestamp? uAt = data['updatedAt'] as Timestamp?;
    return AppUserModel(
      id: id,
      email: (data['email'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'assistant',
      ownerProfessorId: data['ownerProfessorId'] as String?,
      createdAt: cAt?.toDate(),
      updatedAt: uAt?.toDate(),
    );
  }

  Map<String, Object?> toMap({bool forUpdate = false}) {
    return <String, Object?>{
      'email': email,
      'displayName': displayName,
      'role': role,
      if (ownerProfessorId != null) 'ownerProfessorId': ownerProfessorId,
      if (!forUpdate && createdAt == null)
        'createdAt': FieldValue.serverTimestamp()
      else if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser toEntity() =>
      AppUser(id: id, email: email, displayName: displayName, role: role);

  AppUserModel copyWith({
    String? email,
    String? displayName,
    String? role,
    String? ownerProfessorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      ownerProfessorId: ownerProfessorId ?? this.ownerProfessorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
