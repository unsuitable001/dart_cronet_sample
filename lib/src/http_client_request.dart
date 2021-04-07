import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'generated_bindings.dart';

class HttpClientRequest {
  final Uri _uri;
  final String _method;
  final Cronet _cronet;
  final Pointer<Cronet_Engine> _cronet_engine;
  final _CallbackHandler _cbh;

  HttpClientRequest(this._uri, this._method, this._cronet, this._cronet_engine): _cbh = _CallbackHandler(_cronet) {}

  Future<Stream<List<int>>> close() {
    return Future(() {
      Pointer<Cronet_UrlRequest> request = _cronet.Cronet_UrlRequest_Create();
      Pointer<Cronet_UrlRequestParams> request_params = _cronet.Cronet_UrlRequestParams_Create();
      _cronet.Cronet_UrlRequestParams_http_method_set(request_params, _method.toNativeUtf8().cast<Int8>());
      _cronet.Cronet_UrlRequest_Init(request, _cronet_engine, _uri.toString().toNativeUtf8().cast<Int8>(), request_params);
      _cronet.Cronet_UrlRequest_Start(request);
      _cbh.listen();
      return _cbh.stream;
    });
  }

}



class _CallbackRequestMessage {
  final String method;
  final Uint8List data;

  factory _CallbackRequestMessage.fromCppMessage(List message) {
    return _CallbackRequestMessage._(message[0], message[1]);
  }

  _CallbackRequestMessage._(this.method, this.data);

  String toString() => 'CppRequest(method: $method)';
}


class _CallbackHandler {
  final ReceivePort _receivePort = ReceivePort();
  final Cronet cronet;

  final _controller = StreamController<List<int>>();

  _CallbackHandler(this.cronet) {
    
    cronet.registerCallbackHandler(_receivePort.sendPort.nativePort);
  }

  Stream<List<int>> get stream => _controller.stream;

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

          _controller.sink.add(cronet.Cronet_Buffer_GetData(buffer).cast<Uint8>().asTypedList(bytes_read));

//          print("${cronet.Cronet_Buffer_GetData(buffer).cast<Utf8>().toDartString()}");

          cronet.Cronet_UrlRequest_Read(request, buffer);

        }
        break;
        case 'OnFailed':
        case 'OnCanceled':
        case 'OnSucceeded': {
          _receivePort.close();
          _controller.close();
        }
        break;
        default: {
          throw("Unimplemented Callback");
        }
      }

    }).onError((error) => print(error));
  }
}