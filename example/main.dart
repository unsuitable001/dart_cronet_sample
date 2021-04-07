import 'dart:convert';
import 'package:cronet_sample/cronet_sample.dart';




/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */


void main(List<String> args) {
  final stopwatch =  Stopwatch()..start();

  HttpClient client = HttpClient();
  client.getUrl(Uri.parse('http://example.com')).then((HttpClientRequest request) {
    return request.close();
  }).then((Stream<List<int>> response) {
    response.transform(utf8.decoder).listen((contents) {
      print(contents);
    }, onDone: () => print("cronet implemenation took: ${stopwatch.elapsedMilliseconds} ms"));
  });

}


