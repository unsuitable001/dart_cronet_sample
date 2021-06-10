import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io' as io;

import 'package:cronet_sample/src/exceptions.dart';
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
  final String acceptLanguage;
  final CacheMode cacheMode;
  final int? maxCache;
  final List<QuicHint>? quicHints;

  var _enableTimelineLogging = false;
  final _loggingFile =
      io.Directory.systemTemp.createTempSync().uri.resolve('netlog.json');

  final Pointer<Cronet_Engine> _cronetEngine;
  // Keep all the request reference in a list so if the client is being explicitly closed, we can clean up the requests.
  final _requests = List<HttpClientRequest>.empty(growable: true);
  var _stop = false;

  Uri? _temp;

  static const int defaultHttpPort = 80;
  static const int defaultHttpsPort = 443;

  /// Initiates a [HttpClient].
  ///
  /// An optional parameters -
  /// 1. [quic] use QUIC protocol. Default - true. You can also pass [quicHints].
  /// 2. [http2] use HTTP2 protocol. Default - true
  /// 3. [brotli] use brotli compression. Default - true
  /// 4. [acceptLanguage] - Default - 'en_US'
  /// 5. [cacheMode] - Choose from [CacheMode]. Default - [CacheMode.inMemory]
  /// 6. [maxCache] - Set maximum cache size in bytes. Set to `null` to let the system decide. Default - `10KB`.
  /// NOTE: For [CacheMode.inMemory], [maxCache] must not be null. For any other mode, it can be.
  ///
  /// 7. If caches and cookies should persist, provide a directory using [cronetStorage]. Keeping it null will use
  /// a temporary, non persistant storage.
  ///
  /// Throws [CronetException] if [HttpClient] can't be created.
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
      this.acceptLanguage = 'en_US',
      this.cacheMode = CacheMode.inMemory,
      this.maxCache = 10 * 1024,
      io.Directory? cronetStorage})
      : _cronetEngine = _cronet.Cronet_Engine_Create() {
    // Initialize Dart Native API dynamically
    _cronet.InitDartApiDL(NativeApi.initializeApiDLData);
    _cronet.registerHttpClient(this, _cronetEngine);

    // starting the engine with parameters
    final engineParams = _cronet.Cronet_EngineParams_Create();
    _cronet.Cronet_EngineParams_user_agent_set(
        engineParams, userAgent.toNativeUtf8().cast<Int8>());
    _cronet.Cronet_EngineParams_enable_quic_set(engineParams, quic);

    if (quicHints != null) {
      for (final quicHint in quicHints!) {
        final hint = _cronet.Cronet_QuicHint_Create();
        _cronet.Cronet_QuicHint_host_set(
            hint, quicHint.host.toNativeUtf8().cast<Int8>());
        _cronet.Cronet_QuicHint_port_set(hint, quicHint.port);
        _cronet.Cronet_QuicHint_alternate_port_set(
            hint, quicHint.alternatePort);
        _cronet.Cronet_EngineParams_quic_hints_add(engineParams, hint);
        _cronet.Cronet_QuicHint_Destroy(hint);
      }
    }

    _cronet.Cronet_EngineParams_enable_http2_set(engineParams, http2);
    _cronet.Cronet_EngineParams_enable_brotli_set(engineParams, brotli);
    _cronet.Cronet_EngineParams_accept_language_set(
        engineParams, acceptLanguage.toNativeUtf8().cast<Int8>());

    if (cronetStorage == null) {
      // temporary and non-persistant
      cronetStorage = io.Directory.systemTemp.createTempSync();
      _temp = cronetStorage.uri;
    } else {
      // persistant. Why in subfolder? If user
      // chooses a directory by mistake, cronet will override this
      // and it maybe better to store cronet files in a subfolder
      cronetStorage =
          io.Directory.fromUri(cronetStorage.uri.resolve('cronet_storage'));
      cronetStorage.createSync(recursive: true);
    }

    _cronet.Cronet_EngineParams_storage_path_set(
        engineParams, cronetStorage.path.toNativeUtf8().cast<Int8>());

    _cronet.Cronet_EngineParams_http_cache_mode_set(
        engineParams, cacheMode.index);

    if (maxCache != null) {
      _cronet.Cronet_EngineParams_http_cache_max_size_set(
          engineParams, maxCache!);
    }

    final res =
        _cronet.Cronet_Engine_StartWithParams(_cronetEngine, engineParams);
    if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw CronetException(res);
    }
    _cronet.Cronet_EngineParams_Destroy(engineParams);
  }

  void _cleanUpStorage() {
    if (_stop && _requests.isEmpty) {
      if (_temp != null) {
        // deleteing non persistant storage if created
        if (io.Directory.fromUri(_temp!).existsSync()) {
          try {
            io.Directory.fromUri(_temp!).deleteSync(recursive: true);
            _temp = null;
          } catch (e) {
            log("Can't delete the file", error: e);
          }
        }
      }
      // if the folder is empty, delete it.
      if (!io.File.fromUri(_loggingFile).existsSync()) {
        io.File.fromUri(_loggingFile).parent.deleteSync();
      }
    }
  }

  void _cleanUpRequests(HttpClientRequest hcr) {
    _requests.remove(hcr);
  }

  /// Shuts down the HTTP client.
  ///
  /// If [force] is `false` (the default) the HttpClient will be kept alive until all active connections are done. If [force] is `true` any active connections will be closed to immediately release all resources. These closed connections will receive an ~error~ cancel event to indicate that the client was shut down. In both cases trying to establish a new connection after calling close will throw an exception.
  /// NOTE: Temporary storage files (cache, cookies and logs if no explicit path is mentioned) are only deleted if you [close] the engine.
  void close({bool force = false}) {
    if (_stop) {
      // if already stopped, return immediately
      return;
    }
    _stop = true;
    if (force) {
      final requests = _requests
          .toList(); // deep copy the list as the main list will be modified when aborting requests
      for (final request in requests) {
        request.abort();
      }
    }
    _cleanUpStorage();
  }

  Uri _getUri(String host, int port, String path) {
    final _host = Uri.parse(host);
    if (!_host.hasScheme) {
      final scheme = (port == defaultHttpsPort) ? 'https' : 'http';
      return Uri(scheme: scheme, host: host, port: port, path: path);
    } else {
      return Uri(
          scheme: _host.scheme, host: _host.host, port: port, path: path);
    }
  }

  /// Opens a [url] using a [method] like GET, PUT, POST, HEAD, PATCH, DELETE.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future(() {
      if (_stop) {
        throw Exception("Client is closed. Can't open new connections");
      }
      _requests.add(HttpClientRequest(
          url, method, _cronet, _cronetEngine, _cleanUpRequests));
      return _requests.last;
    });
  }

  /// Opens a request on the basis of [method], [host], [port] and [path] using GET, PUT, POST, HEAD, PATCH, DELETE method
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    return openUrl(method, _getUri(host, port, path));
  }

  /// Opens a [url] using GET method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl('GET', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using GET method
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> get(String host, int port, String path) {
    return getUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using HEAD method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> headUrl(Uri url) {
    return openUrl('HEAD', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using HEAD method
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> head(String host, int port, String path) {
    return headUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using PUT method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> putUrl(Uri url) {
    return openUrl('PUT', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using PUT method
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> put(String host, int port, String path) {
    return putUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using POST method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> postUrl(Uri url) {
    return openUrl('POST', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using POST method
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> post(String host, int port, String path) {
    return postUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using PATCH method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> patchUrl(Uri url) {
    return openUrl('PATCH', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using PATCH method
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return patchUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using DELETE method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return openUrl('DELETE', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using DELETE method
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return deleteUrl(_getUri(host, port, path));
  }

  bool get enableTimelineLogging => _enableTimelineLogging;

  /// Enables logging. May content sensitive content.
  /// Path of the log can be get from [logUri].
  ///
  /// If logging can't be started, then a [LoggingException] will be thrown
  set enableTimelineLogging(bool enable) {
    io.File.fromUri(_loggingFile).createSync();
    if (enable) {
      if (!_cronet.Cronet_Engine_StartNetLogToFile(
          _cronetEngine, _loggingFile.path.toNativeUtf8().cast<Int8>(), true)) {
        throw LoggingException();
      }
    } else {
      _cronet.Cronet_Engine_StopNetLog(_cronetEngine);
    }
    _enableTimelineLogging = enable;
  }

  /// get Uri to the log file
  Uri get logUri => _loggingFile;

  /// Function for resolving the proxy server to be used for a HTTP connection from the proxy configuration specified through environment variables.
  ///
  /// Note: It just returns [io.HttpClient.findProxyFromEnvironment].
  static String findProxyFromEnvironment(Uri url,
      {Map<String, String>? environment}) {
    return io.HttpClient.findProxyFromEnvironment(url,
        environment: environment);
  }

  /// Gets Cronet's version
  String get httpClientVersion =>
      _cronet.Cronet_Engine_GetVersionString(_cronetEngine)
          .cast<Utf8>()
          .toDartString();
}
