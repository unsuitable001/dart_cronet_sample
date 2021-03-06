import 'dart:io';

import 'package:cronet_sample/src/http_client.dart';
import 'package:cronet_sample/src/exceptions.dart';
import 'package:test/test.dart';

int main() {
  late HttpClient client;
  setUp(() async {
    client = HttpClient();
  });

  test('Throws HttpException if url do not exist', () async {
    final request = await client.openUrl('GET',
        Uri.parse('http://localghost:9999')); // localghost shouln't exist :p
    final resp = await request.close();
    expect(resp,
        emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
  });

  test('Throws HttpException if the port is wrong', () async {
    final request = await client.openUrl(
        'GET', Uri.parse('http://localhost:9999')); // port 9999 should be close
    final resp = await request.close();
    expect(resp,
        emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
  });

  test('Throws HttpException if the scheme is wrong', () async {
    final request =
        await client.openUrl('GET', Uri.parse('random://localhost:5253'));
    final resp = await request.close();
    expect(resp,
        emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
  });

  tearDown(() {
    client.close();
  });
  return 0;
}
