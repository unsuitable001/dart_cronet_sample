import 'dart:io';

class LoggingException implements Exception {
  LoggingException();
}

class HttpException implements IOException {
  final String message;
  final Uri? uri;

  const HttpException(this.message, {this.uri});

  @override
  String toString() {
    final b = StringBuffer()..write('HttpException: ')..write(message);
    final uri = this.uri;
    if (uri != null) {
      b.write(', uri = $uri');
    }
    return b.toString();
  }
}
