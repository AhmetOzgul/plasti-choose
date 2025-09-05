import 'package:uuid/uuid.dart';

class PatientIdGenerator {
  static const _uuid = Uuid();

  /// Generates a unique patient ID using UUID v4
  static String generateId() {
    return _uuid.v4();
  }

  /// Generates a unique image ID for patient images
  static String generateImageId() {
    return _uuid.v4();
  }
}

class PatientSearchHelper {
  /// Creates search metadata for patient displayName
  /// This enables case-insensitive prefix search in Firestore
  static Map<String, dynamic> createSearchMetadata(String displayName) {
    return {
      'displayName_lc': displayName.toLowerCase(),
      'displayName_tokens': _generateTokens(displayName.toLowerCase()),
    };
  }

  /// Generates search tokens for better search functionality
  /// Splits displayName into words for partial matching
  static List<String> _generateTokens(String displayName) {
    final words = displayName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    final tokens = <String>{};

    // Add full name
    tokens.add(displayName);

    // Add individual words
    tokens.addAll(words);

    // Add word prefixes (for autocomplete)
    for (final word in words) {
      for (int i = 1; i <= word.length; i++) {
        tokens.add(word.substring(0, i));
      }
    }

    return tokens.toList();
  }
}
