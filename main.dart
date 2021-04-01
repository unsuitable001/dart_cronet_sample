import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'generated_bindings.dart';
import 'callback_handler.dart';


final _cronet = Cronet(DynamicLibrary.open('wrapper/wrapper.so'));
/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */


void main(List<String> args) {

  _cronet.InitDartApiDL(NativeApi.initializeApiDLData);

  print("Hello From Cronet");
  ReceivePort _rp = ReceivePort();

  

  CallbackHandler cbh = CallbackHandler(_rp, _cronet);

  Pointer<Cronet_Engine> cronet_engine = _cronet.Cronet_Engine_Create();
  print('Running Cronet Version: ${_cronet.Cronet_Engine_GetVersionString(cronet_engine).cast<Utf8>().toDartString()}');
  Pointer<Cronet_EngineParams> engine_params = _cronet.Cronet_EngineParams_Create();
  _cronet.Cronet_EngineParams_user_agent_set(engine_params, 'CronetSample/1'.toNativeUtf8().cast<Int8>());
  _cronet.Cronet_EngineParams_enable_quic_set(engine_params, true);
  _cronet.Cronet_Engine_StartWithParams(cronet_engine, engine_params);
  _cronet.Cronet_EngineParams_Destroy(engine_params);
  Pointer<Cronet_UrlRequest> request = _cronet.Cronet_UrlRequest_Create();
  Pointer<Cronet_UrlRequestParams> request_params = _cronet.Cronet_UrlRequestParams_Create();
  _cronet.Cronet_UrlRequestParams_http_method_set(request_params, "GET".toNativeUtf8().cast<Int8>());
  _cronet.Cronet_UrlRequest_Init(request, cronet_engine, 'http://example.com'.toNativeUtf8().cast<Int8>(), request_params); 
  _cronet.Cronet_UrlRequest_Start(request);
  cbh.listen();

}


