import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:cronet_sample/cronet_sample.dart';




/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */


void main(List<String> args) {

  cronet.InitDartApiDL(NativeApi.initializeApiDLData);

  print("Hello From Cronet");
  ReceivePort _rp = ReceivePort();

  

  CallbackHandler cbh = CallbackHandler(_rp, cronet);

  Pointer<Cronet_Engine> cronet_engine = cronet.Cronet_Engine_Create();
  print('Running Cronet Version: ${cronet.Cronet_Engine_GetVersionString(cronet_engine).cast<Utf8>().toDartString()}');
  Pointer<Cronet_EngineParams> engine_params = cronet.Cronet_EngineParams_Create();
  cronet.Cronet_EngineParams_user_agent_set(engine_params, 'CronetSample/1'.toNativeUtf8().cast<Int8>());
  cronet.Cronet_EngineParams_enable_quic_set(engine_params, true);
  cronet.Cronet_Engine_StartWithParams(cronet_engine, engine_params);
  cronet.Cronet_EngineParams_Destroy(engine_params);
  Pointer<Cronet_UrlRequest> request = cronet.Cronet_UrlRequest_Create();
  Pointer<Cronet_UrlRequestParams> request_params = cronet.Cronet_UrlRequestParams_Create();
  cronet.Cronet_UrlRequestParams_http_method_set(request_params, "GET".toNativeUtf8().cast<Int8>());
  cronet.Cronet_UrlRequest_Init(request, cronet_engine, 'http://example.com'.toNativeUtf8().cast<Int8>(), request_params); 
  cronet.Cronet_UrlRequest_Start(request);
  cbh.listen();

}


