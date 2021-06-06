import 'dart:convert';
import 'dart:io';

import 'package:cronet_sample/src/http_client.dart';
import 'package:test/test.dart';

void main() {
  late HttpClient client;
  setUp(() {
    client = HttpClient();
  });

  test('Gets Hello, world response from server using getUrl', () async {
    final sentData = 'Hello, world!';
    final server = await HttpServer.bind(InternetAddress.anyIPv6, 5252);
    server.listen((HttpRequest request) {
      request.response.write(sentData);
      request.response.close();
      server.close();
    });

    final request = await client.getUrl(Uri.parse('http://localhost:5252'));
    final resp = await request.close();
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[sentData, emitsDone]));
  });

  test('Gets Hello, world response from server using get method', () async {
    final sentData = 'Hello, world!';
    final server = await HttpServer.bind(InternetAddress.anyIPv6, 5255);
    server.listen((HttpRequest request) {
      request.response.write(sentData);
      request.response.close();
      server.close();
    });

    final request = await client.get('localhost', 5255, '/');
    final resp = await request.close();
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[sentData, emitsDone]));
  });

  test('Gets Hello, world response from server using openUrl method', () async {
    final sentData = 'Hello, world!';
    final server = await HttpServer.bind(InternetAddress.anyIPv6, 5257);
    server.listen((HttpRequest request) {
      request.response.write(sentData);
      request.response.close();
      server.close();
    });

    final request =
        await client.openUrl('GET', Uri.parse('http://localhost:5257'));
    final resp = await request.close();
    final dataStream = resp.transform(utf8.decoder);
    expect(dataStream, emitsInOrder(<dynamic>[sentData, emitsDone]));
  });

  test('Opening new request after client close throws exception', () async {
    client.close();
    expect(
        () async =>
            await client.openUrl('GET', Uri.parse('http://localhost:5259')),
        throwsException);
  });

  // TODO: Implementing exception classes
  // test('Opening an invalid url throws error', () async {
  //   expect(() async => await client.openUrl('GET', Uri.parse('http://localhost:5259')), throwsException);
  // });

  tearDown(() {
    client.close();
  });
}
