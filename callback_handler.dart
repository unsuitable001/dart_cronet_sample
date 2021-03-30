import 'generated_bindings.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:isolate';



class _CallbackRequestMessage {
  final String method;
  // final List data;

  factory _CallbackRequestMessage.fromCppMessage(List message) {
    return _CallbackRequestMessage._(message[0]);
  }

  _CallbackRequestMessage._(this.method);

  String toString() => 'CppRequest(method: $method)';
}


class CallbackHandler {
  final ReceivePort _receivePort;
  CallbackHandler(this._receivePort, Cronet cronet) {
    
    cronet.registerCallbackHandler(_receivePort.sendPort.nativePort);
  }

  void listen() {
    print("cbh listening");
    _receivePort.listen((message) {
      final reqMessage = _CallbackRequestMessage.fromCppMessage(message);
      print('Dart:   Got message: $reqMessage');

      if(reqMessage.method == 'OnReadCompleted') {
        // print(reqMessage.data);
        print("OnResponseStarted");
      } else {
        print("Other callbacks");
      }
    }).onError((error) => print(error));
  }
}