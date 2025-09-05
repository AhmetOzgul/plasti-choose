import 'package:cloud_firestore/cloud_firestore.dart';

final class Patient {
  final String id;
  final String displayName;
  final String? ownerProfessorId;
  final String createdByAssistantId;
  final String status; // NEW, IN_REVIEW, ACCEPTED, REJECTED, SKIPPED
  final List<PatientImage> images;
  final Map<String, dynamic>? search;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewLock? reviewLock;
  final Decision? decision;

  const Patient({
    required this.id,
    required this.displayName,
    this.ownerProfessorId,
    required this.createdByAssistantId,
    required this.status,
    required this.images,
    this.search,
    required this.createdAt,
    required this.updatedAt,
    this.reviewLock,
    this.decision,
  });

  factory Patient.fromMap(Map<String, dynamic> map, String id) {
    return Patient(
      id: id,
      displayName: map['displayName'] ?? '',
      ownerProfessorId: map['ownerProfessorId'],
      createdByAssistantId: map['createdByAssistantId'] ?? '',
      status: map['status'] ?? 'NEW',
      images:
          (map['images'] as List<dynamic>?)
              ?.map((e) => PatientImage.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      search: map['search'] as Map<String, dynamic>?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      reviewLock: map['reviewLock'] != null
          ? ReviewLock.fromMap(map['reviewLock'] as Map<String, dynamic>)
          : null,
      decision: map['decision'] != null
          ? Decision.fromMap(map['decision'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'ownerProfessorId': ownerProfessorId,
      'createdByAssistantId': createdByAssistantId,
      'status': status,
      'images': images.map((e) => e.toMap()).toList(),
      'search': search,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reviewLock': reviewLock?.toMap(),
      'decision': decision?.toMap(),
    };
  }

  Patient copyWith({
    String? id,
    String? displayName,
    String? ownerProfessorId,
    String? createdByAssistantId,
    String? status,
    List<PatientImage>? images,
    Map<String, dynamic>? search,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReviewLock? reviewLock,
    Decision? decision,
  }) {
    return Patient(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      ownerProfessorId: ownerProfessorId ?? this.ownerProfessorId,
      createdByAssistantId: createdByAssistantId ?? this.createdByAssistantId,
      status: status ?? this.status,
      images: images ?? this.images,
      search: search ?? this.search,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewLock: reviewLock ?? this.reviewLock,
      decision: decision ?? this.decision,
    );
  }
}

final class PatientImage {
  final String id;
  final String url;
  final String fileName;
  final int fileSize;
  final String contentType;
  final DateTime uploadedAt;

  const PatientImage({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileSize,
    required this.contentType,
    required this.uploadedAt,
  });

  factory PatientImage.fromMap(Map<String, dynamic> map) {
    return PatientImage(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      contentType: map['contentType'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'fileSize': fileSize,
      'contentType': contentType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}

final class ReviewLock {
  final String lockedBy;
  final DateTime lockedAt;
  final int ttlSeconds;

  const ReviewLock({
    required this.lockedBy,
    required this.lockedAt,
    required this.ttlSeconds,
  });

  factory ReviewLock.fromMap(Map<String, dynamic> map) {
    return ReviewLock(
      lockedBy: map['lockedBy'] ?? '',
      lockedAt: (map['lockedAt'] as Timestamp).toDate(),
      ttlSeconds: map['ttlSeconds'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lockedBy': lockedBy,
      'lockedAt': Timestamp.fromDate(lockedAt),
      'ttlSeconds': ttlSeconds,
    };
  }

  bool get isExpired {
    final now = DateTime.now();
    final expiryTime = lockedAt.add(Duration(seconds: ttlSeconds));
    return now.isAfter(expiryTime);
  }
}

final class Decision {
  final String decidedBy;
  final DateTime decidedAt;
  final String status; // ACCEPTED, REJECTED, SKIPPED

  const Decision({
    required this.decidedBy,
    required this.decidedAt,
    required this.status,
  });

  factory Decision.fromMap(Map<String, dynamic> map) {
    return Decision(
      decidedBy: map['decidedBy'] ?? '',
      decidedAt: (map['decidedAt'] as Timestamp).toDate(),
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'decidedBy': decidedBy,
      'decidedAt': Timestamp.fromDate(decidedAt),
      'status': status,
    };
  }
}
