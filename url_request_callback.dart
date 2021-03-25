import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'generated_bindings.dart';

class SampleUrlRequestCallback {
  late Pointer<Cronet_UrlRequestCallback> _callback;
  static Cronet? _cronet;

  String last_error_message_ = '';
  String response_as_string_ = '';

  
  SampleUrlRequestCallback(Cronet cronet) {
    _cronet = cronet;
  }


  Pointer<Cronet_UrlRequestCallback> GetUrlRequestCallback() {
    if(_cronet == null) {
      throw "Please set the library through constructor";
    } else {
      _callback = _cronet!.Cronet_UrlRequestCallback_CreateWith(
        OnRedirectReceivedFunc, 
        OnResponseStartedFunc, 
        OnReadCompletedFunc, 
        OnSucceededFunc, 
        OnFailedFunc, 
        OnCanceledFunc
      );
      _cronet!.Cronet_UrlRequestCallback_SetClientContext(_callback, 
      _cronet!.Cronet_UrlRequestCallback_GetClientContext(_callback));
      return _callback;
    }
    
  }


  /* Callback Implementations */

  static void _OnRedirectReceived(
    Pointer<Cronet_UrlRequestCallback> _callback,
    Pointer<Cronet_UrlRequest> request, 
    Pointer<Cronet_UrlResponseInfo> info, 
    Pointer<Int8> newLocationUrl) {

    if(_cronet == null) {
      throw "Please set the library through constructor";
    }

    print("OnRedirectReceived called: ${newLocationUrl.cast<Utf8>().toDartString()}");
    _cronet!.Cronet_UrlRequest_FollowRedirect(request);

  }


  static void _OnResponseStarted(
    Pointer<Cronet_UrlRequestCallback> _callback,
    Pointer<Cronet_UrlRequest> request, 
    Pointer<Cronet_UrlResponseInfo> info,
  ) {

    if(_cronet == null) {
      throw "Please set the library through constructor";
    }

    print("OnResponseStarted called.");
    print("HTTP Status: ${_cronet!.Cronet_UrlResponseInfo_http_status_code_get(info)}");
    print('${_cronet!.Cronet_UrlResponseInfo_http_status_text_get(info)}');

    Pointer<Cronet_Buffer> buffer = _cronet!.Cronet_Buffer_Create();
    _cronet!.Cronet_Buffer_InitWithAlloc(buffer, 32 * 1024);
    _cronet!. Cronet_UrlRequest_Read(request, buffer);

  }

  static void _OnReadCompleted(
    Pointer<Cronet_UrlRequestCallback> _callback,
    Pointer<Cronet_UrlRequest> request, 
    Pointer<Cronet_UrlResponseInfo> info,
    Pointer<Cronet_Buffer> buffer, 
    int bytes_read) {

    if(_cronet == null) {
      throw "Please set the library through constructor";
    }

    print("OnReadCompleted called: ${bytes_read}");

    print("${_cronet!.Cronet_Buffer_GetData(buffer).cast<Utf8>().toDartString()}");

    _cronet!.Cronet_UrlRequest_Read(request, buffer);

  }


  static void _OnSucceeded(
    Pointer<Cronet_UrlRequestCallback> _callback,
    Pointer<Cronet_UrlRequest> request, 
    Pointer<Cronet_UrlResponseInfo> info ) {

    print("OnSucceeded called.");

    // TODO: signalling done - true

  }


  static void _OnFailed(
    Pointer<Cronet_UrlRequestCallback> _callback,
    Pointer<Cronet_UrlRequest> request, 
    Pointer<Cronet_UrlResponseInfo> info,
    Pointer<Cronet_Error> error
  ) {

    if(_cronet == null) {
      throw "Please set the library through constructor";
    }

    print("OnFailed called: ");

    print("${_cronet!.Cronet_Error_message_get(error).cast<Utf8>().toDartString()}");

    // TODO: signalling done - false
  }


  static void _OnCanceled(
    Pointer<Cronet_UrlRequestCallback> _callback,
    Pointer<Cronet_UrlRequest> request, 
    Pointer<Cronet_UrlResponseInfo> info,
  ) {
    print( "OnCanceled called.");
    // TODO: signalling done - false
  }


  // Getters

  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnRedirectReceivedFunc>> get OnRedirectReceivedFunc => Pointer.fromFunction(_OnRedirectReceived);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnResponseStartedFunc>> get OnResponseStartedFunc => Pointer.fromFunction(_OnResponseStarted);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnReadCompletedFunc>> get OnReadCompletedFunc => Pointer.fromFunction(_OnReadCompleted);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnSucceededFunc>> get OnSucceededFunc => Pointer.fromFunction(_OnSucceeded);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnFailedFunc>> get OnFailedFunc => Pointer.fromFunction(_OnFailed);
  Pointer<NativeFunction<Cronet_UrlRequestCallback_OnCanceledFunc>> get OnCanceledFunc => Pointer.fromFunction(_OnCanceled);


}