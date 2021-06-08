import 'dart:convert';
import 'dart:io';

import 'package:cronet_sample/src/http_client.dart';
import 'package:test/test.dart';

int main() {
  late HttpServer server;
  final sentData = 'Hello, world!';
  setUp(() async {
    server = await HttpServer.bind(InternetAddress.anyIPv6, 5253);
    server.listen((HttpRequest request) {
      request.response.write(sentData);
      request.response.close();
    });
  });

  test('Opening new request after client close throws exception', () async {
    final client = HttpClient();
    client.close();
    expect(
        () async =>
            await client.openUrl('GET', Uri.parse('http://localhost:5253')),
        throwsException);
  });

  test(
      'Closing the HttpClient after starting a request keeps the previous connection alive',
      () async {
    final client = HttpClient();
    final request =
        await client.openUrl('GET', Uri.parse('http://localhost:5253'));
    final resp = await request.close();
    client.close();
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[equals(sentData), emitsDone]));
  });

  test(
      'Force Closing the HttpClient after starting a request cancels the previous connections',
      () async {
    final client = HttpClient();
    final request =
        await client.openUrl('GET', Uri.parse('http://localhost:5253'));
    final resp = await request.close();
    client.close(force: true);
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[emitsDone]));
  });

  test('Creating a connection after force closing throws an exception',
      () async {
    final client = HttpClient();
    final request =
        await client.openUrl('GET', Uri.parse('http://localhost:5253'));
    client.close(force: true);
    expect(request.close(), throwsException);
  });

  tearDown(() {
    server.close();
  });

  return 0;
}
