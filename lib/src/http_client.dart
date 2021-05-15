import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'dylib_handler.dart';
import 'generated_bindings.dart';
import 'http_client_request.dart';

// Cronet library is loaded in global scope
final _cronet = Cronet(loadWrapper());

/// A client that receives content, such as web pages,
/// from a server using the HTTP, HTTPS, HTTP2, Quic etc. protocol.
///
/// HttpClient contains a number of methods to send an [HttpClientRequest] to an
/// Http server and receive an [Stream] of [List] of [int], analogus to [HttpClientResponse] back.
/// Alternatively, you can also register callbacks for different network events including
/// but not limited to receiving the raw bytes sent by the server.
/// For example, you can use the
/// get, [getUrl], post, and postUrl methods for GET and POST requests, respectively.
///
///
/// TODO: Implement other functions
/// 
/// 
/// Example Usage:
/// ```dart
/// final client = HttpClient();
/// client.getUrl(Uri.parse('https://example.com/'))
///   .then((HttpClientRequest request) {
///   // See [HttpClientRequest] for more info
/// });
/// ```
class HttpClient {
  String userAgent = 'Dart/2.12';
  final Pointer<Cronet_Engine> _cronet_engine;
  final bool quic;

  /// Initiates a [HttpClient].
  ///
  /// An optional parameter [quic] can be provided to
  /// use QUIC protocol.
  HttpClient({this.quic = true})
      : _cronet_engine = _cronet.Cronet_Engine_Create() {
    // Initialize Dart Native API dynamically
    _cronet.InitDartApiDL(NativeApi.initializeApiDLData);
  }

  /// Opens a [url] using a [method] like GET
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future(() {
      final engine_params = _cronet.Cronet_EngineParams_Create();
      _cronet.Cronet_EngineParams_user_agent_set(
          engine_params, userAgent.toNativeUtf8().cast<Int8>());

      // Set quic settings
      _cronet.Cronet_EngineParams_enable_quic_set(engine_params, quic);

      // Starts engine
      _cronet.Cronet_Engine_StartWithParams(_cronet_engine, engine_params);
      _cronet.Cronet_EngineParams_Destroy(engine_params);
      return HttpClientRequest(url, method, _cronet, _cronet_engine);
    });
  }

  Future<HttpClientRequest> get(String host, int port, String path) {
    // TODO: Implement Function
    throw UnimplementedError();
  }

  /// Opens a [url] using GET method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl('GET', url);
  }

  /// Gets Cronet's version
  String get HttpClientVersion =>
      _cronet.Cronet_Engine_GetVersionString(_cronet_engine)
          .cast<Utf8>()
          .toDartString();
}
