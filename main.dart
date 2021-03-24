import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart' as ffi;


import 'generated_bindings.dart';


final _cnlib = Cronet(DynamicLibrary.open('cronet/libcronet.91.0.4456.0.so'));
ReceivePort receivePort = ReceivePort();


void onRedirectReceived(Pointer<Cronet_UrlRequestCallback> urcb, Pointer<Cronet_UrlRequest> ur, Pointer<Cronet_UrlResponseInfo> urinfo, Pointer<Int8> str) {
  print('Redirect Recieved');
  _cnlib.Cronet_UrlRequest_FollowRedirect(ur);
  
}

void onResponseStarted(Pointer<Cronet_UrlRequestCallback> urcb, Pointer<Cronet_UrlRequest> ur, Pointer<Cronet_UrlResponseInfo> urinfo) {
  print('Response Started');
  Pointer<Cronet_Buffer> buff = _cnlib.Cronet_Buffer_Create();
  _cnlib.Cronet_Buffer_InitWithAlloc(buff, 102400);
  _cnlib.Cronet_UrlRequest_Read(ur, buff);
  print(_cnlib.Cronet_Buffer_GetData(buff).cast<ffi.Utf8>().toDartString());
}

void onReadCompleted(Pointer<Cronet_UrlRequestCallback> urcb, Pointer<Cronet_UrlRequest> ur, Pointer<Cronet_UrlResponseInfo> urinfo, Pointer<Cronet_Buffer> buff, int x) {
  print('onReadCompleted');
}


void onSucceeded(Pointer<Cronet_UrlRequestCallback> urcb, Pointer<Cronet_UrlRequest> ur, Pointer<Cronet_UrlResponseInfo> info) {
  print('onSucceeded');
}


void onFailed(Pointer<Cronet_UrlRequestCallback> urcb, Pointer<Cronet_UrlRequest> ur, Pointer<Cronet_UrlResponseInfo> urinfo, Pointer<Cronet_Error> err) {
  print('onFailed');
}

void onCanceled(Pointer<Cronet_UrlRequestCallback> urcb, Pointer<Cronet_UrlRequest> ur, Pointer<Cronet_UrlResponseInfo> urinfo) {
  print('onCanceled');
}

void executorFunc(Pointer<Cronet_Executor> cx, Pointer<Cronet_Runnable> cr) {
  print('executorFunc');
  // _cnlib.Cronet_Runnable_Run(cr);
  Isolate.spawn((message) { _cnlib.Cronet_Runnable_Run(cr); }, receivePort.sendPort);
  
}

void main() {
  final cronet = _cnlib.Cronet_Engine_Create();
  print( 'Running Cronet Version: ${_cnlib.Cronet_Engine_GetVersionString(cronet).cast<ffi.Utf8>().toDartString()}');

  final urlReq = _cnlib.Cronet_UrlRequest_Create();
  final uReqParams = _cnlib.Cronet_UrlRequestParams_Create();


  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnRedirectReceivedFunc>> _onRedirectReceived = Pointer.fromFunction(onRedirectReceived);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnResponseStartedFunc>> _onResponseStarted = Pointer.fromFunction(onResponseStarted);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnReadCompletedFunc>> _onReadCompleted = Pointer.fromFunction(onReadCompleted);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnSucceededFunc>>  _onSucceeded = Pointer.fromFunction(onSucceeded);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnFailedFunc>> _onFailed = Pointer.fromFunction(onFailed);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnCanceledFunc>> _onCanceled = Pointer.fromFunction(onCanceled);

  final callBacks = _cnlib.Cronet_UrlRequestCallback_CreateWith(_onRedirectReceived,_onResponseStarted,_onReadCompleted,_onSucceeded,_onFailed,_onCanceled);

  Pointer<NativeFunction<Cronet_Executor_ExecuteFunc>> execFunc = Pointer.fromFunction(executorFunc);
  final executor = _cnlib.Cronet_Executor_CreateWith(execFunc);


  _cnlib.Cronet_UrlRequest_InitWithParams(urlReq,cronet,'https://www.example.com'.toNativeUtf8().cast<Int8>(),uReqParams,callBacks, executor);

  _cnlib.Cronet_UrlRequest_Start(urlReq);
}


