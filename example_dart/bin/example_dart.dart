import 'dart:convert';
import 'dart:io';
import 'package:cronet_sample/cronet_sample.dart';

/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */

void main(List<String> args) {
  final stopwatch = Stopwatch()..start();
  final client = HttpClient();
  for (var i = 0; i < 3; i++) {
    // Demo - with concurrent requests
    client
        .getUrl(Uri.parse('https://postman-echo.com/headers'))
        .then((HttpClientRequest request) {
      request.headers
          .set(HttpHeaders.cacheControlHeader, 'max-age=3600, must-revalidate');
      if (i == 2) {
        client.close(); // We will shut down the client after 3 connections.
      }
      return request.close();
    }).then((HttpClientResponse response) {
      response.transform(utf8.decoder).listen((contents) {
        print(contents);
      }, onDone: () {
        print('cronet implemenation took: ${stopwatch.elapsedMilliseconds} ms');
      });
    });
  }

  // Alternate API

  final client2 = HttpClient();
  client2
      .getUrl(Uri.parse('http://info.cern.ch/'))
      .then((HttpClientRequest request) {
    request.registerCallbacks((data, bytesRead, responseCode, next) {
      print(utf8.decoder.convert(data));
      print('Status: $responseCode');
      next();
    },
        onSuccess: (responseCode) =>
            print('Done with status: $responseCode')).catchError(
        (e) => print(e));
  });
}
