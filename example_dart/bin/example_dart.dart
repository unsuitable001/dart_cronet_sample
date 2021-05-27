import 'dart:convert';
import 'package:cronet_sample/cronet_sample.dart';

/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */

void main(List<String> args) {
  final stopwatch = Stopwatch()..start();

  final client = HttpClient();
  for(var i = 0; i < 3; i++) {  // Demo - with concurrent requests
      client
      .getUrl(Uri.parse('http://info.cern.ch/'))
      .then((HttpClientRequest request) {
    /* The alternate API introduced.
    NOTE: If we register callbacks & listen to the stream at the same time,
    the stream will be closed immediately executing the onDone callback */

    // request.registerCallbacks(onReadData: (contents, size, next) {
    //   print(utf8.decoder.convert(contents));
    //   next();
    // }, onSuccess: () => print("cronet implemenation took: ${stopwatch.elapsedMilliseconds} ms"));
    return request.close();
  }).then((Stream<List<int>> response) {
    response.transform(utf8.decoder).listen((contents) {
      print(contents);
    },
        onDone: () => print(
            'cronet implemenation took: ${stopwatch.elapsedMilliseconds} ms'));
    });
  }

}
