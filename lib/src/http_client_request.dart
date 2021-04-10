import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'generated_bindings.dart';

typedef RedirectReceivedCallback = void Function(String newLocationUrl);
typedef ResponseStartedCallback = void Function();
typedef ReadDataCallback = void Function(List<int> data, int bytes_read, Function read);   // onReadComplete may confuse people
typedef FailedCallabck = void Function();
typedef CanceledCallabck = void Function();
typedef SuccessCallabck = void Function();


class HttpClientRequest {
  final Uri _uri;
  final String _method;
  final Cronet _cronet;
  final Pointer<Cronet_Engine> _cronet_engine;
  final _CallbackHandler _cbh;

  HttpClientRequest(this._uri, this._method, this._cronet, this._cronet_engine): _cbh = _CallbackHandler(_cronet);

  void registerCallbacks({RedirectReceivedCallback? onRedirectReceived,
    ResponseStartedCallback? onResponseStarted,
    ReadDataCallback? onReadData,
    FailedCallabck? onFailed,
    CanceledCallabck? onCanceled,
    SuccessCallabck? onSuccess}) {
      _cbh.registerCallbacks(onRedirectReceived, onResponseStarted, onReadData, onFailed, onCanceled, onSuccess);

  }


  Future<Stream<List<int>>> close() {
    return Future(() {
      final request = _cronet.Cronet_UrlRequest_Create();
      final request_params = _cronet.Cronet_UrlRequestParams_Create();
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

  factory _CallbackRequestMessage.fromCppMessage(List<dynamic> message) {
    return _CallbackRequestMessage._(message[0] as String, message[1] as Uint8List);
  }

  _CallbackRequestMessage._(this.method, this.data);

  @override
  String toString() => 'CppRequest(method: $method)';
}


class _CallbackHandler {
  final ReceivePort _receivePort = ReceivePort();
  final Cronet cronet;

  final _controller = StreamController<List<int>>();


  RedirectReceivedCallback? _onRedirectReceived;
  ResponseStartedCallback? _onResponseStarted;
  ReadDataCallback? _onReadData;
  FailedCallabck? _onFailed;
  CanceledCallabck? _onCanceled;
  SuccessCallabck? _onSuccess;

  _CallbackHandler(this.cronet) {
    
    cronet.registerCallbackHandler(_receivePort.sendPort.nativePort);
  }

  Stream<List<int>> get stream => _controller.stream;

  void registerCallbacks([RedirectReceivedCallback? onRedirectReceived,
    ResponseStartedCallback? onResponseStarted,
    ReadDataCallback? onReadData,
    FailedCallabck? onFailed,
    CanceledCallabck? onCanceled,
    SuccessCallabck? onSuccess]) {
      _onRedirectReceived = onRedirectReceived;
      _onResponseStarted = onResponseStarted;
      _onReadData = onReadData;
      if(_onReadData != null) {
        _controller.close();
      }
      _onFailed = onFailed;
      _onCanceled = onCanceled;
      _onSuccess = onSuccess;
  }

  void listen() {
    _receivePort.listen((dynamic message) {
      final reqMessage = _CallbackRequestMessage.fromCppMessage(message as List);
      Int64List args;
      args = reqMessage.data.buffer.asInt64List();
      switch(reqMessage.method) {
        case 'OnRedirectReceived': {
          print('New Location: ${Pointer.fromAddress(args[0]).cast<Utf8>().toDartString()}');
          if(_onRedirectReceived != null) {
            _onRedirectReceived!(Pointer.fromAddress(args[0]).cast<Utf8>().toDartString());
          }
        }
        break;
        case 'OnResponseStarted': {
          print('Response started');
          if(_onResponseStarted != null) {
            _onResponseStarted!();
          }
        }
        break;
        case 'OnReadCompleted': {
          final request = Pointer<Cronet_UrlRequest>.fromAddress(args[0]);
          final _ = Pointer<Cronet_UrlResponseInfo>.fromAddress(args[1]);
          final buffer = Pointer<Cronet_Buffer>.fromAddress(args[2]);
          final bytes_read = args[3];

          print('Recieved: $bytes_read');

          if(_onReadData != null) {
            _onReadData!(cronet.Cronet_Buffer_GetData(buffer).cast<Uint8>().asTypedList(bytes_read),
            bytes_read, () => cronet.Cronet_UrlRequest_Read(request, buffer));
          } else {
            _controller.sink.add(cronet.Cronet_Buffer_GetData(buffer).cast<Uint8>().asTypedList(bytes_read));
            cronet.Cronet_UrlRequest_Read(request, buffer);
          }  

        }
        break;
        case 'OnFailed': {
          _receivePort.close();
          if(_onFailed != null) {
          _onFailed!();
          }
          if(_onReadData == null) {
          _controller.close();
          }
        }
        break;
        case 'OnCanceled': {
          _receivePort.close();
          if(_onCanceled != null) {
          _onCanceled!();
          }
          if(_onReadData == null) {
          _controller.close();
          }
        }
        break;
        case 'OnSucceeded': {
          _receivePort.close();
          if(_onSuccess != null) {
            _onSuccess!();
          }
          if(_onReadData == null) {
            _controller.close();
          }
        }
        break;
        default: {
          throw('Unimplemented Callback');
        }
      }

    }, onError: (Object error) {
      print(error);
    });
  }
}