import 'dart:io';

class LoggingException implements Exception {
  const LoggingException();
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

class CronetException implements Exception {
  final int val;
  const CronetException(this.val);

  @override
  String toString() {
    final b = StringBuffer()
      ..write('CronetException: Cronet Result: ')
      ..write(val);
    return b.toString();
  }
}

class UrlRequestException extends CronetException {
  const UrlRequestException(int val) : super(val);
}
