/// Base application exception for Rehiyonia.
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause != null) {
      return '$runtimeType: $message (Caused by: $cause)';
    }
    return '$runtimeType: $message';
  }
}

/// Thrown when local database operations fail.
final class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.cause]);
}

/// Thrown when audio playback or sound loading fails.
final class AudioException extends AppException {
  const AudioException(super.message, [super.cause]);
}

/// Thrown when educational data assets fail parsing or validation.
final class ContentParsingException extends AppException {
  const ContentParsingException(super.message, [super.cause]);
}
