import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'exceptions.dart';

import 'generated_bindings.dart';

part '../third_party/http_headers.dart';
part '../third_party/http_date.dart';

// Type definitions for various callbacks
typedef RedirectReceivedCallback = void Function(String newLocationUrl);
typedef ResponseStartedCallback = void Function();
typedef ReadDataCallback = void Function(List<int> data, int bytesRead,
    Function read); // onReadComplete may confuse people
typedef FailedCallabck = void Function();
typedef CanceledCallabck = void Function();
typedef SuccessCallabck = void Function();

/// HTTP request for a client connection.
///
/// It handles all of the Http Requests made by [HttpClient].
///
/// Provides two ways to get data from the request.
/// [registerCallbacks] or a [Stream] of [List] of [int] like [HttpClientResponse].
///
/// Either of them can be used at a time.
///
///
/// Example Usage:
/// ```dart
/// final client = HttpClient();
/// client.getUrl(Uri.parse('https://example.com/'))
///   .then((HttpClientRequest request) {
///   return request.close();
/// }).then((Stream<List<int>> response) {
///   // Here you got the raw data.
///   // Use it as you like.
/// });
/// ```
///
///
/// TODO: Implement other functions
class HttpClientRequest implements IOSink {
  final Uri _uri;
  final String _method;
  final Cronet _cronet;
  final Pointer<Cronet_Engine> _cronetEngine;
  final _CallbackHandler _cbh;
  final Pointer<Cronet_UrlRequest> _request;

  final _headers = _HttpHeaders('1.1'); // Setting it to HTTP/1.1
  // TODO: See how that affects and do we need to change
  // Negotiated protocol info is only available via Cronet_UrlResponseInfo

  @override
  Encoding encoding;

  /// Initiates a [HttpClientRequest]. It is meant to be used by
  /// [HttpClient]. Takes in [_uri], [_method], [_cronet] instance
  HttpClientRequest(this._uri, this._method, this._cronet, this._cronetEngine,
      Stream<dynamic> receivePortStream, ReceivePort rp,
      {this.encoding = utf8})
      : _cbh = _CallbackHandler(
            _cronet, _cronet.Create_Executor(), receivePortStream),
        _request = _cronet.Cronet_UrlRequest_Create() {
          
        _cronet.registerCallbackHandler(rp.sendPort.nativePort, _request);
      }

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

  /// Cancels the ongoing url request
  ///
  /// Url Request event listners will get a cancel event
  void cancel() {
    _cronet.Cronet_UrlRequest_Cancel(_request);
  }

  /// Returns the [Stream] responsible for
  /// emitting data received from the server
  /// by cronet.
  ///
  /// Consumable similar to [HttpClientResponse]
  @override
  Future<Stream<List<int>>> close() {
    return Future(() {
      _headers._finalize(); // making headers immutable
      final requestParams = _cronet.Cronet_UrlRequestParams_Create();
      _cronet.Cronet_UrlRequestParams_http_method_set(
          requestParams, _method.toNativeUtf8().cast<Int8>());
      headers.forEach((name, values) {
        for (final value in values) {
          final headerPtr = _cronet.Cronet_HttpHeader_Create();
          _cronet.Cronet_HttpHeader_name_set(
              headerPtr, name.toNativeUtf8().cast<Int8>());
          _cronet.Cronet_HttpHeader_value_set(
              headerPtr, value.toNativeUtf8().cast<Int8>());
          _cronet.Cronet_UrlRequestParams_request_headers_add(
              requestParams, headerPtr);
          _cronet.Cronet_HttpHeader_Destroy(headerPtr);
        }
      });
      _cronet.Cronet_UrlRequest_Init(
          _request,
          _cronetEngine,
          _uri.toString().toNativeUtf8().cast<Int8>(),
          requestParams,
          _cbh.executor);
      _cronet.Cronet_UrlRequest_Start(_request);
      _cbh.listen(_request);
      return _cbh.stream;
    });
  }

  /// Aborts the client connection.
  ///
  /// If the connection has not yet completed, the request is aborted
  /// and closes the [Stream] with onDone callback you may have
  /// registered. The [Exception] passed to it is thrown and
  /// [StackTrace] is printed. If there is no [StackTrace] provided,
  /// [StackTrace.empty] will be shown. If no [Exception] is provided,
  /// no exception is thrown.
  ///
  /// If the [Stream] is closed, aborting has no effect.
  void abort([Object? exception, StackTrace? stackTrace]) {
    if (!_cbh._controller.isClosed) {
      _cbh._controller.close().whenComplete(() {
        print(stackTrace ?? StackTrace.empty);
        if (exception is Exception) {
          throw exception;
        }
      });
    }
  }

  /// Done is same as [close]. A [Stream<List<int>>] future that will complete once the response is available.
  /// Analogus to [HttpClientResponse].
  ///
  /// If an error occurs before the response is available, this future will complete with an error.
  @override
  Future<Stream<List<int>>> get done => close();

  @override
  void add(List<int> data) {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  @override
  Future flush() {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  @override
  void write(Object? object) {
    final string = '$object';
    if (string.isEmpty) return;
    add(encoding.encode(string));
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    final iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }

  /// Follow the redirects
  bool get followRedirects => _cbh.followRedirects;
  set followRedirects(bool follow) {
    _cbh.followRedirects = follow;
  }

  /// Maximum numbers of redirects to follow.
  /// Have no effect if [followRedirects] is set to false.
  int get maxRedirects => _cbh.maxRedirects;
  set maxRedirects(int redirects) {
    _cbh.maxRedirects = redirects;
  }

  /// The uri of the request.
  Uri get uri => _uri;

  HttpHeaders get headers => _headers;
}

/// Deserializes the message sent by
/// cronet and it's wrapper
class _CallbackRequestMessage {
  final String method;
  final int uuid;
  final Uint8List data;

  /// Constructs [method], [uuid] (url request pointer) and [data] from [message]
  factory _CallbackRequestMessage.fromCppMessage(List<dynamic> message) {
    return _CallbackRequestMessage._(
        message[0] as String, message[1] as int, message[2] as Uint8List);
  }

  _CallbackRequestMessage._(this.method, this.uuid, this.data);

  @override
  String toString() => 'CppRequest(method: $method)';
}

/// Handles every kind of callbacks that are
/// invoked by messages and data that are sent by
/// [NativePort] from native cronet library.
///
///
class _CallbackHandler {
  final Stream<dynamic> _receivePortStream;
  final Cronet cronet;
  final Pointer<Void> executor;

  // These are a part of HttpClientRequest Public API
  bool followRedirects = true;
  int maxRedirects = 5;

  /// Stream controller to allow consumption of data
  /// like [HttpClientResponse]
  final _controller = StreamController<List<int>>();

  RedirectReceivedCallback? _onRedirectReceived;
  ResponseStartedCallback? _onResponseStarted;
  ReadDataCallback? _onReadData;
  FailedCallabck? _onFailed;
  CanceledCallabck? _onCanceled;
  SuccessCallabck? _onSuccess;

  /// Registers the [NativePort] to the cronet side.
  _CallbackHandler(this.cronet, this.executor, this._receivePortStream);

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
  void listen(Pointer<Cronet_UrlRequest> reqPtr) {
    // registers the listener on the _receivePort.
    // The message parameter contains both the name of the event and
    // the data associated with it.
    StreamSubscription<dynamic>? streamSub;
    streamSub = _receivePortStream.listen((dynamic message) {
      final reqMessage =
          _CallbackRequestMessage.fromCppMessage(message as List);
      final uuid = reqMessage.uuid;
      Int64List args;
      args = reqMessage.data.buffer.asInt64List();

      // If http client is requested to force stop
      if (reqMessage.method == 'force_close') {
        cronet.Cronet_UrlRequest_Cancel(reqPtr);
      }

      // If the message isn't meant for this request
      if (reqPtr.address != uuid) {
        return;
      }
      switch (reqMessage.method) {
        // Invoked when a redirect is received.
        // Currently: Passes the new location's url as parameter.
        case 'OnRedirectReceived':
          {
            print(
                'New Location: ${Pointer.fromAddress(args[0]).cast<Utf8>().toDartString()}');
            if (followRedirects && maxRedirects > 0) {
              cronet.Cronet_UrlRequest_FollowRedirect(reqPtr);
              maxRedirects--;
            } else {
              cronet.Cronet_UrlRequest_Cancel(reqPtr);
            }
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
            final bytesRead = args[3];

            print('Recieved: $bytesRead');

            final data = cronet.Cronet_Buffer_GetData(buffer)
                .cast<Uint8>()
                .asTypedList(bytesRead);

            // invoke the callback
            if (_onReadData != null) {
              _onReadData!(data.toList(growable: false), bytesRead,
                  () => cronet.Cronet_UrlRequest_Read(request, buffer));
            } else {
              // or, add data to the stream
              // why .toList - SEE ISSUE #8
              _controller.sink.add(data.toList(growable: false));
              cronet.Cronet_UrlRequest_Read(request, buffer);
            }
          }
          break;
        // When there is any network error
        // We will shut everything down after this.
        case 'OnFailed':
          {
            streamSub?.cancel();
            if (_onFailed != null) {
              _onFailed!();
            }
            if (_onReadData == null) {
              _controller.close();
              cronet.removeRequest(reqPtr);
            }
          }
          break;
        // when the request is cancelled
        // We will shut everything down after this.
        case 'OnCanceled':
          {
            streamSub?.cancel();
            if (_onCanceled != null) {
              _onCanceled!();
            }
            if (_onReadData == null) {
              _controller.close();
              cronet.removeRequest(reqPtr);
            }
          }
          break;
        // when the request is succesfully done
        // all the data has received.
        // We will shut everything down after this.
        case 'OnSucceeded':
          {
            streamSub?.cancel();
            if (_onSuccess != null) {
              _onSuccess!();
            }
            if (_onReadData == null) {
              _controller.close();
              cronet.removeRequest(reqPtr);
            }
          }
          break;
        default:
          {
            break;
          }
      }
    }, onError: (Object error) {
      print(error);
    });
  }
}
