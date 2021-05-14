import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'generated_bindings.dart';

// Type definitions for various callbacks
typedef RedirectReceivedCallback = void Function(String newLocationUrl);
typedef ResponseStartedCallback = void Function();
typedef ReadDataCallback = void Function(List<int> data, int bytes_read,
    Function read); // onReadComplete may confuse people
typedef FailedCallabck = void Function();
typedef CanceledCallabck = void Function();
typedef SuccessCallabck = void Function();

/// HTTP request for a client connection.
///
/// It handles all of the Http Requests made by [HttpClient].
///
/// Provides two ways to get data from the request.
/// [registerCallbacks] or a [Stream] of [List] of [int] like [dart:io HttpClientResponse].
///
/// Either of them can be used at a time.
class HttpClientRequest {
  final Uri _uri;
  final String _method;
  final Cronet _cronet;
  final Pointer<Cronet_Engine> _cronet_engine;
  final _CallbackHandler _cbh;

  /// Initiates a [HttpClientRequest]. It is meant to be used by
  /// [HttpClient]. Takes in [_uri], [_method], [_cronet] instance and
  /// a C pointer to [_cronet_engine].
  HttpClientRequest(this._uri, this._method, this._cronet, this._cronet_engine)
      : _cbh = _CallbackHandler(_cronet);

  /// This is one of the methods to get data out of [HttpClientRequest].
  /// Accepted callbacks are [RedirectReceivedCallback],
  /// [ResponseStartedCallback], [ReadDataCallback], [FailedCallabck],
  /// [CanceledCallabck] and [SuccessCallabck].
  ///
  /// Callbacks will be called as per sequence of the events.
  void registerCallbacks(
      {RedirectReceivedCallback? onRedirectReceived,
      ResponseStartedCallback? onResponseStarted,
      ReadDataCallback? onReadData,
      FailedCallabck? onFailed,
      CanceledCallabck? onCanceled,
      SuccessCallabck? onSuccess}) {
    _cbh.registerCallbacks(onRedirectReceived, onResponseStarted, onReadData,
        onFailed, onCanceled, onSuccess);
  }

  /// Returns the [Stream] responsible for
  /// emitting data received from the server
  /// by cronet.
  ///
  /// Consumeable similar to [HttpClientResponse]
  Future<Stream<List<int>>> close() {
    return Future(() {
      final request = _cronet.Cronet_UrlRequest_Create();
      final request_params = _cronet.Cronet_UrlRequestParams_Create();
      _cronet.Cronet_UrlRequestParams_http_method_set(
          request_params, _method.toNativeUtf8().cast<Int8>());
      _cronet.Cronet_UrlRequest_Init(request, _cronet_engine,
          _uri.toString().toNativeUtf8().cast<Int8>(), request_params);
      _cronet.Cronet_UrlRequest_Start(request);
      _cbh.listen();
      return _cbh.stream;
    });
  }
}

/// Deserializes the message sent by
/// cronet and it's wrapper
class _CallbackRequestMessage {
  final String method;
  final Uint8List data;

  /// Constructs [method] snd [data] from [message]
  factory _CallbackRequestMessage.fromCppMessage(List<dynamic> message) {
    return _CallbackRequestMessage._(
        message[0] as String, message[1] as Uint8List);
  }

  _CallbackRequestMessage._(this.method, this.data);

  @override
  String toString() => 'CppRequest(method: $method)';
}

/// Handles every kind of callbacks that are
/// invoked by messages and data that are sent by
/// [NativePort] from native cronet library.
///
/// The associated [ReceivePort] is also initiated here.
class _CallbackHandler {
  final ReceivePort _receivePort = ReceivePort();
  final Cronet cronet;

  /// Stream controller to allow consumption of data
  /// like [dart:io HttpClientResponse]
  final _controller = StreamController<List<int>>();

  RedirectReceivedCallback? _onRedirectReceived;
  ResponseStartedCallback? _onResponseStarted;
  ReadDataCallback? _onReadData;
  FailedCallabck? _onFailed;
  CanceledCallabck? _onCanceled;
  SuccessCallabck? _onSuccess;

  /// Registers the [NativePort] to the cronet side.
  _CallbackHandler(this.cronet) {
    cronet.registerCallbackHandler(_receivePort.sendPort.nativePort);
  }

  Stream<List<int>> get stream => _controller.stream;

  /// This sets callbacks that are registered using
  /// [HttpClientRequest.registerCallbacks].
  ///
  /// If [ReadDataCallback] is provided, close the [_controller].
  void registerCallbacks(
      [RedirectReceivedCallback? onRedirectReceived,
      ResponseStartedCallback? onResponseStarted,
      ReadDataCallback? onReadData,
      FailedCallabck? onFailed,
      CanceledCallabck? onCanceled,
      SuccessCallabck? onSuccess]) {
    _onRedirectReceived = onRedirectReceived;
    _onResponseStarted = onResponseStarted;
    _onReadData = onReadData;
    if (_onReadData != null) {
      _controller.close();
    }
    _onFailed = onFailed;
    _onCanceled = onCanceled;
    _onSuccess = onSuccess;
  }

  /// This listens to the messages sent by native cronet library
  /// through wrapper via [NativePort].
  ///
  /// This also invokes the appropriate callbacks that are registered
  /// according to the network events sent from cronet side.
  ///
  /// This is also reponsible for providing a [Stream] of [int]
  /// to create a interface like [HttpClientResponse].
  void listen() {
    // registers the listener on the _receivePort.
    // The message parameter contains both the name of the event and
    // the data associated with it.
    _receivePort.listen((dynamic message) {
      final reqMessage =
          _CallbackRequestMessage.fromCppMessage(message as List);
      Int64List args;
      args = reqMessage.data.buffer.asInt64List();
      switch (reqMessage.method) {
        // Invoked when a redirect is received.
        // TODO: Need a way to control to follow the redirect or not
        // Currently: Passes the new location's url as parameter.
        case 'OnRedirectReceived':
          {
            print(
                'New Location: ${Pointer.fromAddress(args[0]).cast<Utf8>().toDartString()}');
            if (_onRedirectReceived != null) {
              _onRedirectReceived!(
                  Pointer.fromAddress(args[0]).cast<Utf8>().toDartString());
            }
          }
          break;

        // When server has sent the initial response
        case 'OnResponseStarted':
          {
            print('Response started');
            if (_onResponseStarted != null) {
              _onResponseStarted!();
            }
          }
          break;
        // Read a chunk of data.
        // This is where we actually read
        // the response from the server.
        //
        // Data gets added to the stream here.
        // ReadDataCallback is invoked here
        // with data received, no of bytes read
        // and a function which can be called
        // to continue reading.
        case 'OnReadCompleted':
          {
            final request = Pointer<Cronet_UrlRequest>.fromAddress(args[0]);
            final _ = Pointer<Cronet_UrlResponseInfo>.fromAddress(args[1]);
            final buffer = Pointer<Cronet_Buffer>.fromAddress(args[2]);
            final bytes_read = args[3];

            print('Recieved: $bytes_read');

            // invoke the callback
            if (_onReadData != null) {
              _onReadData!(
                  cronet.Cronet_Buffer_GetData(buffer)
                      .cast<Uint8>()
                      .asTypedList(bytes_read),
                  bytes_read,
                  () => cronet.Cronet_UrlRequest_Read(request, buffer));
            } else {
              // or, add data to the stream
              _controller.sink.add(cronet.Cronet_Buffer_GetData(buffer)
                  .cast<Uint8>()
                  .asTypedList(bytes_read));
              cronet.Cronet_UrlRequest_Read(request, buffer);
            }
          }
          break;
        // When there is any network error
        // We will shut everything down after this.
        case 'OnFailed':
          {
            _receivePort.close();
            if (_onFailed != null) {
              _onFailed!();
            }
            if (_onReadData == null) {
              _controller.close();
            }
          }
          break;
        // when the request is cancelled
        // We will shut everything down after this.
        case 'OnCanceled':
          {
            _receivePort.close();
            if (_onCanceled != null) {
              _onCanceled!();
            }
            if (_onReadData == null) {
              _controller.close();
            }
          }
          break;
        // when the request is succesfully done
        // all the data has received.
        // We will shut everything down after this.
        case 'OnSucceeded':
          {
            _receivePort.close();
            if (_onSuccess != null) {
              _onSuccess!();
            }
            if (_onReadData == null) {
              _controller.close();
            }
          }
          break;
        default:
          {
            throw ('Unimplemented Callback');
          }
      }
    }, onError: (Object error) {
      print(error);
    });
  }
}
