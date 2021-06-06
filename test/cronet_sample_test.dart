import 'dart:io';

import 'package:cronet_sample/src/http_client.dart';
import 'package:test/test.dart';

void main() {
  late HttpClient client;
  setUp(() {
    client = HttpClient();
  });

  test('Loads cronet engine and gets the version string', () {
    expect(client.httpClientVersion, TypeMatcher<String>());
  });

  test('Gets the user agent', () {
    expect(client.userAgent, 'Dart/2.12');
  });

  test('Loads another cronet engine with different config', () {
    final client2 = HttpClient(userAgent: 'Dart_Test/1.0');
    expect(client2, TypeMatcher<HttpClient>());
    client2.close();
  });

  test('Creates a logging directory and deletes it if logging is not enabled',
      () {
    expect(client.enableTimelineLogging, false);
    final logUri = client.logUri;
    expect(logUri, TypeMatcher<Uri>());
    final logFile = File.fromUri(logUri);
    expect(logFile.existsSync(), false); // Log File shouldn't be created
    expect(logFile.parent.existsSync(), true);
    client.close();
    expect(logFile.parent.existsSync(), false);
  });

  test(
      'Creates a logging file inside a temporary directory if logging is enabled',
      () {
    client.enableTimelineLogging = true;
    expect(client.enableTimelineLogging, true);
    final logUri = client.logUri;
    final logFile = File.fromUri(logUri);
    expect(logFile.existsSync(), true);
    client.close();
    expect(logFile.existsSync(), true);
  });

  test('Logging file should be kept even if it is disabled mid-way', () {
    client.enableTimelineLogging = true;
    expect(client.enableTimelineLogging, true);
    client.enableTimelineLogging = false;
    expect(client.enableTimelineLogging, false);
    final logUri = client.logUri;
    final logFile = File.fromUri(logUri);
    expect(logFile.existsSync(), true);
    client.close();
    expect(logFile.existsSync(), true);
  });

  // TODO: Implementing exception classes for engine creating failure

  tearDown(() {
    client.close();
  });
}
