import 'dart:io';

import 'package:cronet_sample/src/http_client.dart';
import 'package:test/test.dart';

void main() {
  late HttpClient client;
  setUp(() {
    client = HttpClient();
  });

  test('Validate static constants', () {
    expect(80, equals(HttpClient.defaultHttpPort));
    expect(443, equals(HttpClient.defaultHttpsPort));
  });

  test('Loads cronet engine and gets the version string', () {
    expect(client.httpClientVersion, TypeMatcher<String>());
  });

  test('Gets the user agent', () {
    expect(client.userAgent, equals('Dart/2.12'));
  });

  test('Loads another cronet engine with different config', () {
    final client2 = HttpClient(userAgent: 'Dart_Test/1.0');
    expect(client2, TypeMatcher<HttpClient>());
    expect(client2.userAgent, equals('Dart_Test/1.0'));
    client2.close();
  });

  test('Creates a logging directory and deletes it if logging is not enabled',
      () {
    expect(client.enableTimelineLogging, equals(false));
    final logUri = client.logUri;
    expect(logUri, TypeMatcher<Uri>());
    final logFile = File.fromUri(logUri);
    expect(
        logFile.existsSync(), equals(false)); // Log File shouldn't be created
    expect(logFile.parent.existsSync(), equals(true));
    client.close();
    expect(logFile.parent.existsSync(), equals(false));
  });

  test(
      'Creates a logging file inside a temporary directory if logging is enabled',
      () {
    client.enableTimelineLogging = true;
    expect(client.enableTimelineLogging, equals(true));
    final logUri = client.logUri;
    final logFile = File.fromUri(logUri);
    expect(logFile.existsSync(), equals(true));
    client.close();
    expect(logFile.existsSync(), equals(true));
  });

  test('Logging file should be kept even if it is disabled mid-way', () {
    client.enableTimelineLogging = true;
    expect(client.enableTimelineLogging, equals(true));
    client.enableTimelineLogging = false;
    expect(client.enableTimelineLogging, equals(false));
    final logUri = client.logUri;
    final logFile = File.fromUri(logUri);
    expect(logFile.existsSync(), equals(true));
    client.close();
    expect(logFile.existsSync(), equals(true));
  });

  tearDown(() {
    client.close();
  });
}
