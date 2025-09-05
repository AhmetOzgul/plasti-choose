/// Authenticated application user entity.
final class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'assistant' | 'professor'
  final String? ownerProfessorId; // For assistants, the professor they work for

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.ownerProfessorId,
  });

  bool isProfessor() => role == 'professor';
  bool isAssistant() => role == 'assistant';
}
