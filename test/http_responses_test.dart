import 'dart:convert';
import 'dart:io';

import 'package:cronet_sample/src/http_client.dart';
import 'package:test/test.dart';

void main() {
  late HttpClient client;
  late HttpServer server;
  final sentData = 'Hello, world!';
  setUp(() async {
    client = HttpClient();
    server = await HttpServer.bind(InternetAddress.anyIPv6, 5252);
    server.listen((HttpRequest request) {
      request.response.write(sentData);
      request.response.close();
    });
  });

  test('Gets Hello, world response from server using getUrl', () async {
    final request = await client.getUrl(Uri.parse('http://localhost:5252'));
    final resp = await request.close();
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[equals(sentData), emitsDone]));
  });

  test('Gets Hello, world response from server using get method', () async {
    final request = await client.get('localhost', 5252, '/');
    final resp = await request.close();
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[equals(sentData), emitsDone]));
  });

  test('Gets Hello, world response from server using openUrl method', () async {
    final request =
        await client.openUrl('GET', Uri.parse('http://localhost:5252'));
    final resp = await request.close();
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[equals(sentData), emitsDone]));
  });

  // TODO: Implementing exception classes
  // test('Opening an invalid url throws error', () async {
  //   expect(() async => await client.openUrl('GET', Uri.parse('http://localhost:5259')), throwsException);
  // });

  tearDown(() {
    client.close();
    server.close();
  });
}
