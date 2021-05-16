import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cronet_sample/cronet_sample.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String data = '';
  bool _fetching = false;
  final client = HttpClient();
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    request();
    request(); // SEE issue #8
    super.initState();
  }

  void request() {
    setState(() {
      _fetching = true;
    });
    client
        .getUrl(Uri.parse('http://info.cern.ch/'))
        .then((HttpClientRequest request) {
      _stopwatch.start();

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
        setState(() {
          data += contents;
        });
      }, onDone: () {
        _stopwatch.stop();
        setState(() {
          _fetching = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(children: [
          Text('Cronet Version: ${client.HttpClientVersion}'),
          _fetching
              ? CircularProgressIndicator()
              : Expanded(child: SingleChildScrollView(child: Text('$data'))),
          Text('Time taken: ${_stopwatch.elapsedMilliseconds} ms')
        ])),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Fetch Data',
          child: Icon(Icons.arrow_right_alt_outlined),
          onPressed: () => request(),
        ),
      ),
    );
  }
}
