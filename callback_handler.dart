import 'dart:typed_data';

import 'generated_bindings.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:isolate';



class _CallbackRequestMessage {
  final String method;
  final Uint8List data;

  factory _CallbackRequestMessage.fromCppMessage(List message) {
    return _CallbackRequestMessage._(message[0], message[1]);
  }

  _CallbackRequestMessage._(this.method, this.data);

  String toString() => 'CppRequest(method: $method)';
}


class CallbackHandler {
  final ReceivePort _receivePort;
  final Cronet cronet;
  CallbackHandler(this._receivePort, this.cronet) {
    
    cronet.registerCallbackHandler(_receivePort.sendPort.nativePort);
  }

  void listen() {
    _receivePort.listen((message) {
      final reqMessage = _CallbackRequestMessage.fromCppMessage(message);
      Int64List args;
      args = reqMessage.data.buffer.asInt64List();
      switch(reqMessage.method) {
        case 'OnRedirectReceived': {
          print("New Location: ${Pointer.fromAddress(args[0]).cast<Utf8>().toDartString()}");
        }
        break;
        case 'OnResponseStarted': {
          print("Response started");
        }
        break;
        case 'OnReadCompleted': {
          Pointer<Cronet_UrlRequest> request = Pointer.fromAddress(args[0]);
          Pointer<Cronet_UrlResponseInfo> info = Pointer.fromAddress(args[1]);
          Pointer<Cronet_Buffer> buffer = Pointer.fromAddress(args[2]);
          int bytes_read = args[3];

          print("Recieved: ${bytes_read}");

          print("${cronet.Cronet_Buffer_GetData(buffer).cast<Utf8>().toDartString()}");

          cronet.Cronet_UrlRequest_Read(request, buffer);

        }
        break;
        case 'OnFailed':
        case 'OnCanceled':
        case 'OnSucceeded': {
          _receivePort.close();
        }
        break;
        default: {
          throw("Unimplemented Callback");
        }
      }

      // if(reqMessage.method == 'OnReadCompleted') {
      //   print("OnResponseStarted");
      // } else {
      //   print("Other callbacks");
      // }
    }).onError((error) => print(error));
  }
}