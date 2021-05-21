// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to Cronet
class Cronet {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  Cronet(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  Cronet.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void registerCallbackHandler(
    int nativePort,
  ) {
    return _registerCallbackHandler(
      nativePort,
    );
  }

  late final _registerCallbackHandler_ptr =
      _lookup<ffi.NativeFunction<_c_registerCallbackHandler>>(
          'registerCallbackHandler');
  late final _dart_registerCallbackHandler _registerCallbackHandler =
      _registerCallbackHandler_ptr.asFunction<_dart_registerCallbackHandler>();

  void dispatchCallback(
    ffi.Pointer<ffi.Int8> methodname,
  ) {
    return _dispatchCallback(
      methodname,
    );
  }

  late final _dispatchCallback_ptr =
      _lookup<ffi.NativeFunction<_c_dispatchCallback>>('dispatchCallback');
  late final _dart_dispatchCallback _dispatchCallback =
      _dispatchCallback_ptr.asFunction<_dart_dispatchCallback>();

  int InitDartApiDL(
    ffi.Pointer<ffi.Void> data,
  ) {
    return _InitDartApiDL(
      data,
    );
  }

  late final _InitDartApiDL_ptr =
      _lookup<ffi.NativeFunction<_c_InitDartApiDL>>('InitDartApiDL');
  late final _dart_InitDartApiDL _InitDartApiDL =
      _InitDartApiDL_ptr.asFunction<_dart_InitDartApiDL>();

  void registerHttpClient(
    Object h,
  ) {
    return _registerHttpClient(
      h,
    );
  }

  late final _registerHttpClient_ptr =
      _lookup<ffi.NativeFunction<_c_registerHttpClient>>('registerHttpClient');
  late final _dart_registerHttpClient _registerHttpClient =
      _registerHttpClient_ptr.asFunction<_dart_registerHttpClient>();

  ffi.Pointer<Cronet_Engine> Cronet_Engine_Create() {
    return _Cronet_Engine_Create();
  }

  late final _Cronet_Engine_Create_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_Engine_Create>>(
          'Cronet_Engine_Create');
  late final _dart_Cronet_Engine_Create _Cronet_Engine_Create =
      _Cronet_Engine_Create_ptr.asFunction<_dart_Cronet_Engine_Create>();

  ffi.Pointer<ffi.Int8> Cronet_Engine_GetVersionString(
    ffi.Pointer<Cronet_Engine> self,
  ) {
    return _Cronet_Engine_GetVersionString(
      self,
    );
  }

  late final _Cronet_Engine_GetVersionString_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_Engine_GetVersionString>>(
          'Cronet_Engine_GetVersionString');
  late final _dart_Cronet_Engine_GetVersionString
      _Cronet_Engine_GetVersionString = _Cronet_Engine_GetVersionString_ptr
          .asFunction<_dart_Cronet_Engine_GetVersionString>();

  ffi.Pointer<Cronet_EngineParams> Cronet_EngineParams_Create() {
    return _Cronet_EngineParams_Create();
  }

  late final _Cronet_EngineParams_Create_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_EngineParams_Create>>(
          'Cronet_EngineParams_Create');
  late final _dart_Cronet_EngineParams_Create _Cronet_EngineParams_Create =
      _Cronet_EngineParams_Create_ptr.asFunction<
          _dart_Cronet_EngineParams_Create>();

  void Cronet_EngineParams_Destroy(
    ffi.Pointer<Cronet_EngineParams> self,
  ) {
    return _Cronet_EngineParams_Destroy(
      self,
    );
  }

  late final _Cronet_EngineParams_Destroy_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_EngineParams_Destroy>>(
          'Cronet_EngineParams_Destroy');
  late final _dart_Cronet_EngineParams_Destroy _Cronet_EngineParams_Destroy =
      _Cronet_EngineParams_Destroy_ptr.asFunction<
          _dart_Cronet_EngineParams_Destroy>();

  void Cronet_EngineParams_enable_check_result_set(
    ffi.Pointer<Cronet_EngineParams> self,
    bool enable_check_result,
  ) {
    return _Cronet_EngineParams_enable_check_result_set(
      self,
      enable_check_result ? 1 : 0,
    );
  }

  late final _Cronet_EngineParams_enable_check_result_set_ptr = _lookup<
          ffi.NativeFunction<_c_Cronet_EngineParams_enable_check_result_set>>(
      'Cronet_EngineParams_enable_check_result_set');
  late final _dart_Cronet_EngineParams_enable_check_result_set
      _Cronet_EngineParams_enable_check_result_set =
      _Cronet_EngineParams_enable_check_result_set_ptr.asFunction<
          _dart_Cronet_EngineParams_enable_check_result_set>();

  void Cronet_EngineParams_user_agent_set(
    ffi.Pointer<Cronet_EngineParams> self,
    ffi.Pointer<ffi.Int8> user_agent,
  ) {
    return _Cronet_EngineParams_user_agent_set(
      self,
      user_agent,
    );
  }

  late final _Cronet_EngineParams_user_agent_set_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_EngineParams_user_agent_set>>(
          'Cronet_EngineParams_user_agent_set');
  late final _dart_Cronet_EngineParams_user_agent_set
      _Cronet_EngineParams_user_agent_set =
      _Cronet_EngineParams_user_agent_set_ptr.asFunction<
          _dart_Cronet_EngineParams_user_agent_set>();

  void Cronet_EngineParams_enable_quic_set(
    ffi.Pointer<Cronet_EngineParams> self,
    bool enable_quic,
  ) {
    return _Cronet_EngineParams_enable_quic_set(
      self,
      enable_quic ? 1 : 0,
    );
  }

  late final _Cronet_EngineParams_enable_quic_set_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_EngineParams_enable_quic_set>>(
          'Cronet_EngineParams_enable_quic_set');
  late final _dart_Cronet_EngineParams_enable_quic_set
      _Cronet_EngineParams_enable_quic_set =
      _Cronet_EngineParams_enable_quic_set_ptr.asFunction<
          _dart_Cronet_EngineParams_enable_quic_set>();

  int Cronet_Engine_StartWithParams(
    ffi.Pointer<Cronet_Engine> self,
    ffi.Pointer<Cronet_EngineParams> params,
  ) {
    return _Cronet_Engine_StartWithParams(
      self,
      params,
    );
  }

  late final _Cronet_Engine_StartWithParams_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_Engine_StartWithParams>>(
          'Cronet_Engine_StartWithParams');
  late final _dart_Cronet_Engine_StartWithParams
      _Cronet_Engine_StartWithParams = _Cronet_Engine_StartWithParams_ptr
          .asFunction<_dart_Cronet_Engine_StartWithParams>();

  int Cronet_Engine_Shutdown(
    ffi.Pointer<Cronet_Engine> self,
  ) {
    return _Cronet_Engine_Shutdown(
      self,
    );
  }

  late final _Cronet_Engine_Shutdown_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_Engine_Shutdown>>(
          'Cronet_Engine_Shutdown');
  late final _dart_Cronet_Engine_Shutdown _Cronet_Engine_Shutdown =
      _Cronet_Engine_Shutdown_ptr.asFunction<_dart_Cronet_Engine_Shutdown>();

  ffi.Pointer<Cronet_UrlRequest> Cronet_UrlRequest_Create() {
    return _Cronet_UrlRequest_Create();
  }

  late final _Cronet_UrlRequest_Create_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_Create>>(
          'Cronet_UrlRequest_Create');
  late final _dart_Cronet_UrlRequest_Create _Cronet_UrlRequest_Create =
      _Cronet_UrlRequest_Create_ptr.asFunction<
          _dart_Cronet_UrlRequest_Create>();

  void Cronet_UrlRequest_Destroy(
    ffi.Pointer<Cronet_UrlRequest> self,
  ) {
    return _Cronet_UrlRequest_Destroy(
      self,
    );
  }

  late final _Cronet_UrlRequest_Destroy_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_Destroy>>(
          'Cronet_UrlRequest_Destroy');
  late final _dart_Cronet_UrlRequest_Destroy _Cronet_UrlRequest_Destroy =
      _Cronet_UrlRequest_Destroy_ptr.asFunction<
          _dart_Cronet_UrlRequest_Destroy>();

  void Cronet_UrlRequest_SetClientContext(
    ffi.Pointer<Cronet_UrlRequest> self,
    ffi.Pointer<ffi.Void> client_context,
  ) {
    return _Cronet_UrlRequest_SetClientContext(
      self,
      client_context,
    );
  }

  late final _Cronet_UrlRequest_SetClientContext_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_SetClientContext>>(
          'Cronet_UrlRequest_SetClientContext');
  late final _dart_Cronet_UrlRequest_SetClientContext
      _Cronet_UrlRequest_SetClientContext =
      _Cronet_UrlRequest_SetClientContext_ptr.asFunction<
          _dart_Cronet_UrlRequest_SetClientContext>();

  ffi.Pointer<ffi.Void> Cronet_UrlRequest_GetClientContext(
    ffi.Pointer<Cronet_UrlRequest> self,
  ) {
    return _Cronet_UrlRequest_GetClientContext(
      self,
    );
  }

  late final _Cronet_UrlRequest_GetClientContext_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_GetClientContext>>(
          'Cronet_UrlRequest_GetClientContext');
  late final _dart_Cronet_UrlRequest_GetClientContext
      _Cronet_UrlRequest_GetClientContext =
      _Cronet_UrlRequest_GetClientContext_ptr.asFunction<
          _dart_Cronet_UrlRequest_GetClientContext>();

  ffi.Pointer<Cronet_UrlRequestParams> Cronet_UrlRequestParams_Create() {
    return _Cronet_UrlRequestParams_Create();
  }

  late final _Cronet_UrlRequestParams_Create_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequestParams_Create>>(
          'Cronet_UrlRequestParams_Create');
  late final _dart_Cronet_UrlRequestParams_Create
      _Cronet_UrlRequestParams_Create = _Cronet_UrlRequestParams_Create_ptr
          .asFunction<_dart_Cronet_UrlRequestParams_Create>();

  void Cronet_UrlRequestParams_http_method_set(
    ffi.Pointer<Cronet_UrlRequestParams> self,
    ffi.Pointer<ffi.Int8> http_method,
  ) {
    return _Cronet_UrlRequestParams_http_method_set(
      self,
      http_method,
    );
  }

  late final _Cronet_UrlRequestParams_http_method_set_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequestParams_http_method_set>>(
          'Cronet_UrlRequestParams_http_method_set');
  late final _dart_Cronet_UrlRequestParams_http_method_set
      _Cronet_UrlRequestParams_http_method_set =
      _Cronet_UrlRequestParams_http_method_set_ptr.asFunction<
          _dart_Cronet_UrlRequestParams_http_method_set>();

  int Cronet_UrlRequest_Start(
    ffi.Pointer<Cronet_UrlRequest> self,
  ) {
    return _Cronet_UrlRequest_Start(
      self,
    );
  }

  late final _Cronet_UrlRequest_Start_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_Start>>(
          'Cronet_UrlRequest_Start');
  late final _dart_Cronet_UrlRequest_Start _Cronet_UrlRequest_Start =
      _Cronet_UrlRequest_Start_ptr.asFunction<_dart_Cronet_UrlRequest_Start>();

  int Cronet_UrlRequest_FollowRedirect(
    ffi.Pointer<Cronet_UrlRequest> self,
  ) {
    return _Cronet_UrlRequest_FollowRedirect(
      self,
    );
  }

  late final _Cronet_UrlRequest_FollowRedirect_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_FollowRedirect>>(
          'Cronet_UrlRequest_FollowRedirect');
  late final _dart_Cronet_UrlRequest_FollowRedirect
      _Cronet_UrlRequest_FollowRedirect = _Cronet_UrlRequest_FollowRedirect_ptr
          .asFunction<_dart_Cronet_UrlRequest_FollowRedirect>();

  int Cronet_UrlRequest_Read(
    ffi.Pointer<Cronet_UrlRequest> self,
    ffi.Pointer<Cronet_Buffer> buffer,
  ) {
    return _Cronet_UrlRequest_Read(
      self,
      buffer,
    );
  }

  late final _Cronet_UrlRequest_Read_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_Read>>(
          'Cronet_UrlRequest_Read');
  late final _dart_Cronet_UrlRequest_Read _Cronet_UrlRequest_Read =
      _Cronet_UrlRequest_Read_ptr.asFunction<_dart_Cronet_UrlRequest_Read>();

  int Cronet_UrlRequest_Init(
    ffi.Pointer<Cronet_UrlRequest> self,
    ffi.Pointer<Cronet_Engine> engine,
    ffi.Pointer<ffi.Int8> url,
    ffi.Pointer<Cronet_UrlRequestParams> params,
  ) {
    return _Cronet_UrlRequest_Init(
      self,
      engine,
      url,
      params,
    );
  }

  late final _Cronet_UrlRequest_Init_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_UrlRequest_Init>>(
          'Cronet_UrlRequest_Init');
  late final _dart_Cronet_UrlRequest_Init _Cronet_UrlRequest_Init =
      _Cronet_UrlRequest_Init_ptr.asFunction<_dart_Cronet_UrlRequest_Init>();

  int Cronet_Buffer_GetSize(
    ffi.Pointer<Cronet_Buffer> self,
  ) {
    return _Cronet_Buffer_GetSize(
      self,
    );
  }

  late final _Cronet_Buffer_GetSize_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_Buffer_GetSize>>(
          'Cronet_Buffer_GetSize');
  late final _dart_Cronet_Buffer_GetSize _Cronet_Buffer_GetSize =
      _Cronet_Buffer_GetSize_ptr.asFunction<_dart_Cronet_Buffer_GetSize>();

  ffi.Pointer<ffi.Void> Cronet_Buffer_GetData(
    ffi.Pointer<Cronet_Buffer> self,
  ) {
    return _Cronet_Buffer_GetData(
      self,
    );
  }

  late final _Cronet_Buffer_GetData_ptr =
      _lookup<ffi.NativeFunction<_c_Cronet_Buffer_GetData>>(
          'Cronet_Buffer_GetData');
  late final _dart_Cronet_Buffer_GetData _Cronet_Buffer_GetData =
      _Cronet_Buffer_GetData_ptr.asFunction<_dart_Cronet_Buffer_GetData>();
}

class Cronet_Buffer extends ffi.Opaque {}

class Cronet_BufferCallback extends ffi.Opaque {}

class Cronet_Runnable extends ffi.Opaque {}

class Cronet_Executor extends ffi.Opaque {}

class Cronet_Engine extends ffi.Opaque {}

class Cronet_UrlRequestStatusListener extends ffi.Opaque {}

class Cronet_UrlRequestCallback extends ffi.Opaque {}

class Cronet_UploadDataSink extends ffi.Opaque {}

class Cronet_UploadDataProvider extends ffi.Opaque {}

class Cronet_UrlRequest extends ffi.Opaque {}

class Cronet_RequestFinishedInfoListener extends ffi.Opaque {}

class Cronet_Error extends ffi.Opaque {}

class Cronet_QuicHint extends ffi.Opaque {}

class Cronet_PublicKeyPins extends ffi.Opaque {}

class Cronet_EngineParams extends ffi.Opaque {}

class Cronet_HttpHeader extends ffi.Opaque {}

class Cronet_UrlResponseInfo extends ffi.Opaque {}

class Cronet_UrlRequestParams extends ffi.Opaque {}

class Cronet_DateTime extends ffi.Opaque {}

class Cronet_Metrics extends ffi.Opaque {}

class Cronet_RequestFinishedInfo extends ffi.Opaque {}

abstract class Cronet_RESULT {
  static const int Cronet_RESULT_SUCCESS = 0;
  static const int Cronet_RESULT_ILLEGAL_ARGUMENT = -100;
  static const int Cronet_RESULT_ILLEGAL_ARGUMENT_STORAGE_PATH_MUST_EXIST =
      -101;
  static const int Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_PIN = -102;
  static const int Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HOSTNAME = -103;
  static const int Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HTTP_METHOD = -104;
  static const int Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HTTP_HEADER = -105;
  static const int Cronet_RESULT_ILLEGAL_STATE = -200;
  static const int Cronet_RESULT_ILLEGAL_STATE_STORAGE_PATH_IN_USE = -201;
  static const int
      Cronet_RESULT_ILLEGAL_STATE_CANNOT_SHUTDOWN_ENGINE_FROM_NETWORK_THREAD =
      -202;
  static const int Cronet_RESULT_ILLEGAL_STATE_ENGINE_ALREADY_STARTED = -203;
  static const int Cronet_RESULT_ILLEGAL_STATE_REQUEST_ALREADY_STARTED = -204;
  static const int Cronet_RESULT_ILLEGAL_STATE_REQUEST_NOT_INITIALIZED = -205;
  static const int Cronet_RESULT_ILLEGAL_STATE_REQUEST_ALREADY_INITIALIZED =
      -206;
  static const int Cronet_RESULT_ILLEGAL_STATE_REQUEST_NOT_STARTED = -207;
  static const int Cronet_RESULT_ILLEGAL_STATE_UNEXPECTED_REDIRECT = -208;
  static const int Cronet_RESULT_ILLEGAL_STATE_UNEXPECTED_READ = -209;
  static const int Cronet_RESULT_ILLEGAL_STATE_READ_FAILED = -210;
  static const int Cronet_RESULT_NULL_POINTER = -300;
  static const int Cronet_RESULT_NULL_POINTER_HOSTNAME = -301;
  static const int Cronet_RESULT_NULL_POINTER_SHA256_PINS = -302;
  static const int Cronet_RESULT_NULL_POINTER_EXPIRATION_DATE = -303;
  static const int Cronet_RESULT_NULL_POINTER_ENGINE = -304;
  static const int Cronet_RESULT_NULL_POINTER_URL = -305;
  static const int Cronet_RESULT_NULL_POINTER_CALLBACK = -306;
  static const int Cronet_RESULT_NULL_POINTER_EXECUTOR = -307;
  static const int Cronet_RESULT_NULL_POINTER_METHOD = -308;
  static const int Cronet_RESULT_NULL_POINTER_HEADER_NAME = -309;
  static const int Cronet_RESULT_NULL_POINTER_HEADER_VALUE = -310;
  static const int Cronet_RESULT_NULL_POINTER_PARAMS = -311;
  static const int
      Cronet_RESULT_NULL_POINTER_REQUEST_FINISHED_INFO_LISTENER_EXECUTOR = -312;
}

abstract class Cronet_Error_ERROR_CODE {
  static const int Cronet_Error_ERROR_CODE_ERROR_CALLBACK = 0;
  static const int Cronet_Error_ERROR_CODE_ERROR_HOSTNAME_NOT_RESOLVED = 1;
  static const int Cronet_Error_ERROR_CODE_ERROR_INTERNET_DISCONNECTED = 2;
  static const int Cronet_Error_ERROR_CODE_ERROR_NETWORK_CHANGED = 3;
  static const int Cronet_Error_ERROR_CODE_ERROR_TIMED_OUT = 4;
  static const int Cronet_Error_ERROR_CODE_ERROR_CONNECTION_CLOSED = 5;
  static const int Cronet_Error_ERROR_CODE_ERROR_CONNECTION_TIMED_OUT = 6;
  static const int Cronet_Error_ERROR_CODE_ERROR_CONNECTION_REFUSED = 7;
  static const int Cronet_Error_ERROR_CODE_ERROR_CONNECTION_RESET = 8;
  static const int Cronet_Error_ERROR_CODE_ERROR_ADDRESS_UNREACHABLE = 9;
  static const int Cronet_Error_ERROR_CODE_ERROR_QUIC_PROTOCOL_FAILED = 10;
  static const int Cronet_Error_ERROR_CODE_ERROR_OTHER = 11;
}

abstract class Cronet_EngineParams_HTTP_CACHE_MODE {
  static const int Cronet_EngineParams_HTTP_CACHE_MODE_DISABLED = 0;
  static const int Cronet_EngineParams_HTTP_CACHE_MODE_IN_MEMORY = 1;
  static const int Cronet_EngineParams_HTTP_CACHE_MODE_DISK_NO_HTTP = 2;
  static const int Cronet_EngineParams_HTTP_CACHE_MODE_DISK = 3;
}

abstract class Cronet_UrlRequestParams_REQUEST_PRIORITY {
  static const int
      Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_IDLE = 0;
  static const int
      Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_LOWEST = 1;
  static const int
      Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_LOW = 2;
  static const int
      Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_MEDIUM = 3;
  static const int
      Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_HIGHEST = 4;
}

abstract class Cronet_UrlRequestParams_IDEMPOTENCY {
  static const int Cronet_UrlRequestParams_IDEMPOTENCY_DEFAULT_IDEMPOTENCY = 0;
  static const int Cronet_UrlRequestParams_IDEMPOTENCY_IDEMPOTENT = 1;
  static const int Cronet_UrlRequestParams_IDEMPOTENCY_NOT_IDEMPOTENT = 2;
}

abstract class Cronet_RequestFinishedInfo_FINISHED_REASON {
  static const int Cronet_RequestFinishedInfo_FINISHED_REASON_SUCCEEDED = 0;
  static const int Cronet_RequestFinishedInfo_FINISHED_REASON_FAILED = 1;
  static const int Cronet_RequestFinishedInfo_FINISHED_REASON_CANCELED = 2;
}

abstract class Cronet_UrlRequestStatusListener_Status {
  static const int Cronet_UrlRequestStatusListener_Status_INVALID = -1;
  static const int Cronet_UrlRequestStatusListener_Status_IDLE = 0;
  static const int
      Cronet_UrlRequestStatusListener_Status_WAITING_FOR_STALLED_SOCKET_POOL =
      1;
  static const int
      Cronet_UrlRequestStatusListener_Status_WAITING_FOR_AVAILABLE_SOCKET = 2;
  static const int Cronet_UrlRequestStatusListener_Status_WAITING_FOR_DELEGATE =
      3;
  static const int Cronet_UrlRequestStatusListener_Status_WAITING_FOR_CACHE = 4;
  static const int Cronet_UrlRequestStatusListener_Status_DOWNLOADING_PAC_FILE =
      5;
  static const int
      Cronet_UrlRequestStatusListener_Status_RESOLVING_PROXY_FOR_URL = 6;
  static const int
      Cronet_UrlRequestStatusListener_Status_RESOLVING_HOST_IN_PAC_FILE = 7;
  static const int
      Cronet_UrlRequestStatusListener_Status_ESTABLISHING_PROXY_TUNNEL = 8;
  static const int Cronet_UrlRequestStatusListener_Status_RESOLVING_HOST = 9;
  static const int Cronet_UrlRequestStatusListener_Status_CONNECTING = 10;
  static const int Cronet_UrlRequestStatusListener_Status_SSL_HANDSHAKE = 11;
  static const int Cronet_UrlRequestStatusListener_Status_SENDING_REQUEST = 12;
  static const int Cronet_UrlRequestStatusListener_Status_WAITING_FOR_RESPONSE =
      13;
  static const int Cronet_UrlRequestStatusListener_Status_READING_RESPONSE = 14;
}

typedef _c_registerCallbackHandler = ffi.Void Function(
  ffi.Int64 nativePort,
);

typedef _dart_registerCallbackHandler = void Function(
  int nativePort,
);

typedef _c_dispatchCallback = ffi.Void Function(
  ffi.Pointer<ffi.Int8> methodname,
);

typedef _dart_dispatchCallback = void Function(
  ffi.Pointer<ffi.Int8> methodname,
);

typedef _c_InitDartApiDL = ffi.IntPtr Function(
  ffi.Pointer<ffi.Void> data,
);

typedef _dart_InitDartApiDL = int Function(
  ffi.Pointer<ffi.Void> data,
);

typedef _c_registerHttpClient = ffi.Void Function(
  ffi.Handle h,
);

typedef _dart_registerHttpClient = void Function(
  Object h,
);

typedef _c_Cronet_Engine_Create = ffi.Pointer<Cronet_Engine> Function();

typedef _dart_Cronet_Engine_Create = ffi.Pointer<Cronet_Engine> Function();

typedef _c_Cronet_Engine_GetVersionString = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<Cronet_Engine> self,
);

typedef _dart_Cronet_Engine_GetVersionString = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<Cronet_Engine> self,
);

typedef _c_Cronet_EngineParams_Create = ffi.Pointer<Cronet_EngineParams>
    Function();

typedef _dart_Cronet_EngineParams_Create = ffi.Pointer<Cronet_EngineParams>
    Function();

typedef _c_Cronet_EngineParams_Destroy = ffi.Void Function(
  ffi.Pointer<Cronet_EngineParams> self,
);

typedef _dart_Cronet_EngineParams_Destroy = void Function(
  ffi.Pointer<Cronet_EngineParams> self,
);

typedef _c_Cronet_EngineParams_enable_check_result_set = ffi.Void Function(
  ffi.Pointer<Cronet_EngineParams> self,
  ffi.Uint8 enable_check_result,
);

typedef _dart_Cronet_EngineParams_enable_check_result_set = void Function(
  ffi.Pointer<Cronet_EngineParams> self,
  int enable_check_result,
);

typedef _c_Cronet_EngineParams_user_agent_set = ffi.Void Function(
  ffi.Pointer<Cronet_EngineParams> self,
  ffi.Pointer<ffi.Int8> user_agent,
);

typedef _dart_Cronet_EngineParams_user_agent_set = void Function(
  ffi.Pointer<Cronet_EngineParams> self,
  ffi.Pointer<ffi.Int8> user_agent,
);

typedef _c_Cronet_EngineParams_enable_quic_set = ffi.Void Function(
  ffi.Pointer<Cronet_EngineParams> self,
  ffi.Uint8 enable_quic,
);

typedef _dart_Cronet_EngineParams_enable_quic_set = void Function(
  ffi.Pointer<Cronet_EngineParams> self,
  int enable_quic,
);

typedef _c_Cronet_Engine_StartWithParams = ffi.Int32 Function(
  ffi.Pointer<Cronet_Engine> self,
  ffi.Pointer<Cronet_EngineParams> params,
);

typedef _dart_Cronet_Engine_StartWithParams = int Function(
  ffi.Pointer<Cronet_Engine> self,
  ffi.Pointer<Cronet_EngineParams> params,
);

typedef _c_Cronet_Engine_Shutdown = ffi.Int32 Function(
  ffi.Pointer<Cronet_Engine> self,
);

typedef _dart_Cronet_Engine_Shutdown = int Function(
  ffi.Pointer<Cronet_Engine> self,
);

typedef _c_Cronet_UrlRequest_Create = ffi.Pointer<Cronet_UrlRequest> Function();

typedef _dart_Cronet_UrlRequest_Create = ffi.Pointer<Cronet_UrlRequest>
    Function();

typedef _c_Cronet_UrlRequest_Destroy = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _dart_Cronet_UrlRequest_Destroy = void Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _c_Cronet_UrlRequest_SetClientContext = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequest> self,
  ffi.Pointer<ffi.Void> client_context,
);

typedef _dart_Cronet_UrlRequest_SetClientContext = void Function(
  ffi.Pointer<Cronet_UrlRequest> self,
  ffi.Pointer<ffi.Void> client_context,
);

typedef _c_Cronet_UrlRequest_GetClientContext = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _dart_Cronet_UrlRequest_GetClientContext = ffi.Pointer<ffi.Void>
    Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _c_Cronet_UrlRequestParams_Create = ffi.Pointer<Cronet_UrlRequestParams>
    Function();

typedef _dart_Cronet_UrlRequestParams_Create
    = ffi.Pointer<Cronet_UrlRequestParams> Function();

typedef _c_Cronet_UrlRequestParams_http_method_set = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequestParams> self,
  ffi.Pointer<ffi.Int8> http_method,
);

typedef _dart_Cronet_UrlRequestParams_http_method_set = void Function(
  ffi.Pointer<Cronet_UrlRequestParams> self,
  ffi.Pointer<ffi.Int8> http_method,
);

typedef _c_Cronet_UrlRequest_Start = ffi.Int32 Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _dart_Cronet_UrlRequest_Start = int Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _c_Cronet_UrlRequest_FollowRedirect = ffi.Int32 Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _dart_Cronet_UrlRequest_FollowRedirect = int Function(
  ffi.Pointer<Cronet_UrlRequest> self,
);

typedef _c_Cronet_UrlRequest_Read = ffi.Int32 Function(
  ffi.Pointer<Cronet_UrlRequest> self,
  ffi.Pointer<Cronet_Buffer> buffer,
);

typedef _dart_Cronet_UrlRequest_Read = int Function(
  ffi.Pointer<Cronet_UrlRequest> self,
  ffi.Pointer<Cronet_Buffer> buffer,
);

typedef _c_Cronet_UrlRequest_Init = ffi.Int32 Function(
  ffi.Pointer<Cronet_UrlRequest> self,
  ffi.Pointer<Cronet_Engine> engine,
  ffi.Pointer<ffi.Int8> url,
  ffi.Pointer<Cronet_UrlRequestParams> params,
);

typedef _dart_Cronet_UrlRequest_Init = int Function(
  ffi.Pointer<Cronet_UrlRequest> self,
  ffi.Pointer<Cronet_Engine> engine,
  ffi.Pointer<ffi.Int8> url,
  ffi.Pointer<Cronet_UrlRequestParams> params,
);

typedef _c_Cronet_Buffer_GetSize = ffi.Uint64 Function(
  ffi.Pointer<Cronet_Buffer> self,
);

typedef _dart_Cronet_Buffer_GetSize = int Function(
  ffi.Pointer<Cronet_Buffer> self,
);

typedef _c_Cronet_Buffer_GetData = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<Cronet_Buffer> self,
);

typedef _dart_Cronet_Buffer_GetData = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<Cronet_Buffer> self,
);
