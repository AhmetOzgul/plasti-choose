/// Authenticated application user entity.
final class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'assistant' | 'professor'
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });
  bool isProfessor() => role == 'professor';
  bool isAssistant() => role == 'assistant';
}
