import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'exceptions.dart';

import 'generated_bindings.dart';

part '../third_party/http_headers.dart';
part '../third_party/http_date.dart';
part 'http_client_response.dart';
part 'http_callback_handler.dart';

// Type definitions for various callbacks
typedef RedirectReceivedCallback = void Function(
    String newLocationUrl, int responseCode);
typedef ResponseStartedCallback = void Function(int responseCode);
typedef ReadDataCallback = void Function(List<int> data, int bytesRead,
    int responseCode, Function next); // onReadComplete may confuse people
typedef FailedCallabck = void Function(HttpException exception);
typedef CanceledCallabck = void Function();
typedef SuccessCallabck = void Function(int responseCode);

/// HTTP request for a client connection.
///
/// It handles all of the Http Requests made by [HttpClient].
///
/// Provides two ways to get data from the request.
/// [registerCallbacks] or a [HttpClientResponse] which is a [Stream<List<int>>].
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
/// }).then((HttpClientResponse response) {
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
  final Function _clientCleanup;
  bool _isAborted = false;

  // TODO: See how that affects and do we need to change
  // Negotiated protocol info is only available via Cronet_UrlResponseInfo
  final _headers = _HttpHeaders('1.1'); // Setting it to HTTP/1.1

  @override
  Encoding encoding;

  /// Initiates a [HttpClientRequest]. It is meant to be used by
  /// [HttpClient]. Takes in [_uri], [_method], [_cronet] instance
  HttpClientRequest(this._uri, this._method, this._cronet, this._cronetEngine,
      this._clientCleanup,
      {this.encoding = utf8})
      : _cbh =
            _CallbackHandler(_cronet, _cronet.Create_Executor(), ReceivePort()),
        _request = _cronet.Cronet_UrlRequest_Create() {
    // Register the native port to C side
    _cronet.registerCallbackHandler(
        _cbh.receivePort.sendPort.nativePort, _request);
  }

  // Starts the request
  void _startRequest() {
    if (_isAborted) {
      throw Exception('Request is already aborted');
    }
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
    final res = _cronet.Cronet_UrlRequest_Init(
        _request,
        _cronetEngine,
        _uri.toString().toNativeUtf8().cast<Int8>(),
        requestParams,
        _cbh.executor);

    if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw UrlRequestException(res);
    }

    final res2 = _cronet.Cronet_UrlRequest_Start(_request);
    if (res2 != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw UrlRequestException(res2);
    }
    _cbh.listen(_request, () => _clientCleanup(this));
  }

  /// This is one of the methods to get data out of [HttpClientRequest].
  /// Accepted callbacks are [RedirectReceivedCallback],
  /// [ResponseStartedCallback], [ReadDataCallback], [FailedCallabck],
  /// [CanceledCallabck] and [SuccessCallabck].
  ///
  /// Callbacks will be called as per sequence of the events.
  ///If callbacks are registered, the [Stream] returned by [close] will be closed.
  Future<void> registerCallbacks(ReadDataCallback onReadData,
      {RedirectReceivedCallback? onRedirectReceived,
      ResponseStartedCallback? onResponseStarted,
      FailedCallabck? onFailed,
      CanceledCallabck? onCanceled,
      SuccessCallabck? onSuccess}) {
    final rc = _cbh.registerCallbacks(onReadData, onRedirectReceived,
        onResponseStarted, onFailed, onCanceled, onSuccess);
    _startRequest();
    return rc;
  }

  /// Returns the [Stream] responsible for
  /// emitting data received from the server
  /// by cronet.
  ///
  /// Throws [Exception] if request is already aborted using [abort].
  ///
  /// Throws [UrlRequestException] if request can't be initiated.
  ///
  /// Consumable similar to [HttpClientResponse]
  @override
  Future<HttpClientResponse> close() {
    return Future(() {
      _startRequest();
      return HttpClientResponse._(_cbh.stream);
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
    if (_isAborted) return;
    _isAborted = true;
    _cronet.Cronet_UrlRequest_Cancel(_request);
    _clientCleanup(this);
    _cbh._controller.done.then((dynamic _) {
      log('client aborted: ', stackTrace: stackTrace);
      if (exception is Exception) {
        throw exception;
      }
    });
  }

  /// Done is same as [close]. A [HttpClientResponse] future that will complete once the response is available.
  ///
  /// If an error occurs before the response is available, this future will complete with an error.
  @override
  Future<HttpClientResponse> get done => close();

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
  final Uint8List data;

  /// Constructs [method] and [data] from [message]
  factory _CallbackRequestMessage.fromCppMessage(List<dynamic> message) {
    return _CallbackRequestMessage._(
        message[0] as String, message[1] as Uint8List);
  }

  _CallbackRequestMessage._(this.method, this.data);

  @override
  String toString() => 'CppRequest(method: $method)';
}
