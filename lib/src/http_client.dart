import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'generated_bindings.dart';
import 'http_client_request.dart';

final _cronet = Platform.isAndroid
    ? Cronet(DynamicLibrary.open('libwrapper.so'))
    : Cronet(DynamicLibrary.open('./wrapper.so'));

class HttpClient {
  String userAgent = 'Dart/2.12';
  final Pointer<Cronet_Engine> _cronet_engine;
  final bool quic;

  HttpClient({this.quic = true})
      : _cronet_engine = _cronet.Cronet_Engine_Create() {
    _cronet.InitDartApiDL(NativeApi.initializeApiDLData);
  }

  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future(() {
      final engine_params = _cronet.Cronet_EngineParams_Create();
      _cronet.Cronet_EngineParams_user_agent_set(
          engine_params, userAgent.toNativeUtf8().cast<Int8>());
      _cronet.Cronet_EngineParams_enable_quic_set(engine_params, quic);
      _cronet.Cronet_Engine_StartWithParams(_cronet_engine, engine_params);
      _cronet.Cronet_EngineParams_Destroy(engine_params);
      return HttpClientRequest(url, method, _cronet, _cronet_engine);
    });
  }

  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl('GET', url);
  }

  String get HttpClientVersion =>
      _cronet.Cronet_Engine_GetVersionString(_cronet_engine)
          .cast<Utf8>()
          .toDartString();
}
