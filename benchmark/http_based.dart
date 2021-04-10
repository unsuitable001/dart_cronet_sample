import 'dart:convert';
import 'dart:io';

int main(List<String> args) {

  final stopwatch =  Stopwatch()..start();

  final client = HttpClient();
  client.getUrl(Uri.parse('http://info.cern.ch/')).then((HttpClientRequest request) {
    return request.close();
  }).then((HttpClientResponse response) {
    response.transform(utf8.decoder).listen((contents) {
      print(contents);
    }, onDone: () => print('dart:io implemenation took: ${stopwatch.elapsedMilliseconds} ms'));
  });


  return 0;
}