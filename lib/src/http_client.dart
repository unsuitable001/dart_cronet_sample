import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'dylib_handler.dart';
import 'enums.dart';
import 'generated_bindings.dart';
import 'http_client_request.dart';
import 'quic_hint.dart';

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
  final String userAgent;
  final bool quic;
  final bool http2;
  final bool brotli;
  final String accept_language;
  final CacheMode cacheMode;
  final int? maxCache;
  final List<QuicHint>? quicHints;

  final Pointer<Cronet_Engine> _cronet_engine;
  final ReceivePort _receivePort = ReceivePort();
  late Stream _receivePortBroadcast;
  var _stop = false;

  Directory? dir;

  /// Initiates a [HttpClient].
  ///
  /// An optional parameters -
  /// 1. [quic] use QUIC protocol. Default - true. You can also pass [quicHints].
  /// 2. [http2] use HTTP2 protocol. Default - true
  /// 3. [brotli] use brotli compression. Default - true
  /// 4. [accept_language] - Default - 'en_US'
  /// 5. [cacheMode] - Choose from [CacheMode]. Default - [CacheMode.in_memory]
  /// 6. [maxCache] - Set maximum cache size in bytes. Set to `null` to let the system decide. Default - `10KB`.
  /// NOTE: For [CacheMode.in_memory], [maxCache] must not be null. For any other mode, it can be.
  ///
  /// Breaking Changes from `dart:io` based library:
  ///
  /// 1. [userAgent] property must be set when constructing [HttpClient] and can't be changed afterwards.
  HttpClient(
      {this.userAgent = 'Dart/2.12',
      this.quic = true,
      this.quicHints,
      this.http2 = true,
      this.brotli = true,
      this.accept_language = 'en_US',
      this.cacheMode = CacheMode.in_memory,
      this.maxCache = 100 * 1024})
      : _cronet_engine = _cronet.Cronet_Engine_Create() {
    // Initialize Dart Native API dynamically
    _cronet.InitDartApiDL(NativeApi.initializeApiDLData);
    _cronet.registerHttpClient(this);

    // starting the engine with parameters
    final engine_params = _cronet.Cronet_EngineParams_Create();
    _cronet.Cronet_EngineParams_user_agent_set(
        engine_params, userAgent.toNativeUtf8().cast<Int8>());
    _cronet.Cronet_EngineParams_enable_quic_set(engine_params, quic);

    if (quicHints != null) {
      quicHints?.forEach((quicHint) {
        final hint = _cronet.Cronet_QuicHint_Create();
        _cronet.Cronet_QuicHint_host_set(
            hint, quicHint.host.toNativeUtf8().cast<Int8>());
        _cronet.Cronet_QuicHint_port_set(hint, quicHint.port);
        _cronet.Cronet_QuicHint_alternate_port_set(
            hint, quicHint.alternate_port);
        _cronet.Cronet_EngineParams_quic_hints_add(engine_params, hint);
        _cronet.Cronet_QuicHint_Destroy(hint);
      });
    }

    _cronet.Cronet_EngineParams_enable_http2_set(engine_params, http2);
    _cronet.Cronet_EngineParams_enable_brotli_set(engine_params, brotli);
    _cronet.Cronet_EngineParams_accept_language_set(
        engine_params, accept_language.toNativeUtf8().cast<Int8>());

    switch (cacheMode) {
      case CacheMode.disk:
      case CacheMode.disk_no_http:
        dir = Directory.systemTemp.createTempSync();
        _cronet.Cronet_EngineParams_storage_path_set(
            engine_params, dir!.path.toNativeUtf8().cast<Int8>());
        break;
      default:
        break;
    }

    _cronet.Cronet_EngineParams_http_cache_mode_set(
        engine_params, cacheMode.index);

    if (maxCache != null) {
      _cronet.Cronet_EngineParams_http_cache_max_size_set(
          engine_params, maxCache!);
    } else if (cacheMode == CacheMode.in_memory) {
      // if cache size isn't set and it's in memory cache
      _cronet.Cronet_EngineParams_http_cache_max_size_set(
          engine_params, 10 * 1024);
    }

    _cronet.Cronet_Engine_StartWithParams(_cronet_engine, engine_params);
    _cronet.Cronet_EngineParams_Destroy(engine_params);

    // Register the native port to C side
    _cronet.registerCallbackHandler(_receivePort.sendPort.nativePort);
    // Convert the recieve port stream to broadcast - for concurrent requests
    _receivePortBroadcast =
        _receivePort.asBroadcastStream(onListen: (streamsub) {
      streamsub.resume();
    }, onCancel: (streamsub) {
      if (_stop) {
        streamsub.cancel();
        _receivePort.close();
        dir?.deleteSync(recursive: true);
      } else {
        streamsub.pause();
      }
    });
  }

  /// Shuts down the HTTP client.
  ///
  /// If [force] is `false` (the default) the HttpClient will be kept alive until all active connections are done. If [force] is `true` any active connections will be closed to immediately release all resources. These closed connections will receive an ~error~ cancel event to indicate that the client was shut down. In both cases trying to establish a new connection after calling close will throw an exception.
  void close({bool force = false}) {
    if (force) {
      _stop = true;
      _receivePort.sendPort.send(['force_close', 0, Uint8List(0)]);
    } else {
      _stop = true;
    }
  }

  /// Opens a [url] using a [method] like GET
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future(() {
      if (_stop) {
        throw Exception('Client is closed. Can\'t open new connections');
      }
      return HttpClientRequest(
          url, method, _cronet, _cronet_engine, _receivePortBroadcast);
    });
  }

  /// Opens a request on the basis of [host], [port] and [path] using GET method/
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> get(String host, int port, String path) {
    final _host = Uri.parse(host);
    if (!_host.hasScheme) {
      throw Exception('Scheme not mentioned! $host');
    }
    return getUrl(
        Uri(scheme: _host.scheme, host: _host.host, port: port, path: path));
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
