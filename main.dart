import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'generated_bindings.dart';

import 'url_request_callback.dart';
import 'sample_executor.dart';


final _cronet = Cronet(DynamicLibrary.open('cronet/libcronet.91.0.4456.0.so'));

/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */

Pointer<Cronet_Engine> CreateCronetEngine() {
  Pointer<Cronet_Engine> cronet_engine = _cronet.Cronet_Engine_Create();
  Pointer<Cronet_EngineParams> engine_params = _cronet.Cronet_EngineParams_Create();
  _cronet.Cronet_EngineParams_user_agent_set(engine_params, 'CronetSample/1'.toNativeUtf8().cast<Int8>());
  _cronet.Cronet_EngineParams_enable_quic_set(engine_params, true);
  _cronet.Cronet_Engine_StartWithParams(cronet_engine, engine_params);
  _cronet.Cronet_EngineParams_Destroy(engine_params);
  return cronet_engine;
}

Future<void> PerformRequest(
  Pointer<Cronet_Engine> cronet_engine,
  String url,
  Pointer<Cronet_Executor> executor
) async {

  SampleUrlRequestCallback url_request_callback = SampleUrlRequestCallback(_cronet);
  Pointer<Cronet_UrlRequest> request = _cronet.Cronet_UrlRequest_Create();
  Pointer<Cronet_UrlRequestParams> request_params = _cronet.Cronet_UrlRequestParams_Create();
  _cronet.Cronet_UrlRequestParams_http_method_set(request_params, "GET".toNativeUtf8().cast<Int8>());
  _cronet.Cronet_UrlRequest_InitWithParams(request,cronet_engine,url.toNativeUtf8().cast<Int8>(),request_params,url_request_callback.GetUrlRequestCallback(), executor);
  _cronet.Cronet_UrlRequest_Start(request);

  // TODO: REMOVE Hardcoded value. Will probably use future callbacks in future.
  await Future.delayed(const Duration(seconds: 5), () => _cronet.Cronet_UrlRequest_Destroy(request));
}

void main(List<String> args) {

  print("Hello From Cronet");
  
  Pointer<Cronet_Engine> cronet_engine = CreateCronetEngine();
  print('Running Cronet Version: ${_cronet.Cronet_Engine_GetVersionString(cronet_engine).cast<Utf8>().toDartString()}');

  SampleExecutor executor = SampleExecutor(_cronet);
  PerformRequest(cronet_engine, 'http://example.com', executor.executor).then((_) {
    _cronet.Cronet_Engine_Shutdown(cronet_engine);
    _cronet.Cronet_Engine_Destroy(cronet_engine);
  });
}


