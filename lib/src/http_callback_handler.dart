part of 'http_client_request.dart';

/// Handles every kind of callbacks that are
/// invoked by messages and data that are sent by
/// [NativePort] from native cronet library.
///
///
class _CallbackHandler {
  final ReceivePort receivePort;
  final Cronet cronet;
  final Pointer<Void> executor;

  // These are a part of HttpClientRequest Public API
  bool followRedirects = true;
  int maxRedirects = 5;

  /// Stream controller to allow consumption of data
  /// like [HttpClientResponse]
  final _controller = StreamController<List<int>>();

  Completer<void>?
      _callBackCompleter; // if callback based api is used, completes when receiving data is done

  RedirectReceivedCallback? _onRedirectReceived;
  ResponseStartedCallback? _onResponseStarted;
  ReadDataCallback? _onReadData;
  FailedCallabck? _onFailed;
  CanceledCallabck? _onCanceled;
  SuccessCallabck? _onSuccess;

  /// Registers the [NativePort] to the cronet side.
  _CallbackHandler(this.cronet, this.executor, this.receivePort);

  Stream<List<int>> get stream => _controller.stream;

  /// This sets callbacks that are registered using
  /// [HttpClientRequest.registerCallbacks].
  ///
  /// If [ReadDataCallback] is provided, the [Stream] returned by [HttpClientResponse.close] will be closed.
  Future<void> registerCallbacks(ReadDataCallback onReadData,
      [RedirectReceivedCallback? onRedirectReceived,
      ResponseStartedCallback? onResponseStarted,
      FailedCallabck? onFailed,
      CanceledCallabck? onCanceled,
      SuccessCallabck? onSuccess]) {
    _onRedirectReceived = onRedirectReceived;
    _onResponseStarted = onResponseStarted;
    _onReadData = onReadData;
    _controller.close(); // if callbacks are registered, close the contoller
    // responsible the sream for close() method (dart:io style API)
    _onFailed = onFailed;
    _onCanceled = onCanceled;
    _onSuccess = onSuccess;
    _callBackCompleter = Completer<void>();
    return _callBackCompleter!.future;
  }

  // clean up tasks for a request
  // need to call then whenever we are done with the request
  // either successfully or unsuccessfully.
  void cleanUpRequest(
      Pointer<Cronet_UrlRequest> reqPtr, Function cleanUpClient) {
    receivePort.close();
    cronet.removeRequest(reqPtr);
    cleanUpClient();
  }

  int statusChecker(Pointer<Cronet_UrlResponseInfo> respInfoPtr, int lBound,
      int uBound, Function callback) {
    final respCode =
        cronet.Cronet_UrlResponseInfo_http_status_code_get(respInfoPtr);
    if (!(respCode >= lBound && respCode <= uBound)) {
      // if NOT in range
      callback();
      final exception = HttpException(
          cronet.Cronet_UrlResponseInfo_http_status_text_get(respInfoPtr)
              .cast<Utf8>()
              .toDartString());

      if (_callBackCompleter != null) {
        // if callbacks are registered
        _callBackCompleter!.completeError(exception);
      } else {
        _controller.addError(exception);
        _controller.close();
      }
    }
    return respCode;
  }

  /// This listens to the messages sent by native cronet library
  /// through wrapper via [NativePort].
  ///
  /// This also invokes the appropriate callbacks that are registered
  /// according to the network events sent from cronet side.
  ///
  /// This is also reponsible for providing a [Stream] of [int]
  /// to create a interface like [HttpClientResponse].
  void listen(Pointer<Cronet_UrlRequest> reqPtr, Function cleanUpClient) {
    // registers the listener on the receivePort.
    // The message parameter contains both the name of the event and
    // the data associated with it.
    receivePort.listen((dynamic message) {
      final reqMessage =
          _CallbackRequestMessage.fromCppMessage(message as List);
      Int64List args;
      args = reqMessage.data.buffer.asInt64List();

      switch (reqMessage.method) {
        // Invoked when a redirect is received.
        // Passes the new location's url and response code as parameter
        case 'OnRedirectReceived':
          {
            log('New Location: ${Pointer.fromAddress(args[0]).cast<Utf8>().toDartString()}');
            final respCode = statusChecker(
                Pointer.fromAddress(args[1]).cast<Cronet_UrlResponseInfo>(),
                300,
                399,
                () => cleanUpRequest(reqPtr,
                    cleanUpClient)); // If NOT a 3XX status code, throw Exception
            if (followRedirects && maxRedirects > 0) {
              final res = cronet.Cronet_UrlRequest_FollowRedirect(reqPtr);
              if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
                cleanUpRequest(reqPtr, cleanUpClient);
                throw UrlRequestException(res);
              }
              maxRedirects--;
            } else {
              cronet.Cronet_UrlRequest_Cancel(reqPtr);
            }
            if (_onRedirectReceived != null) {
              _onRedirectReceived!(
                  Pointer.fromAddress(args[0]).cast<Utf8>().toDartString(),
                  respCode);
            }
          }
          break;

        // When server has sent the initial response
        case 'OnResponseStarted':
          {
            final respCode = statusChecker(
                Pointer.fromAddress(args[0]).cast<Cronet_UrlResponseInfo>(),
                100,
                299,
                () => cleanUpRequest(reqPtr,
                    cleanUpClient)); // If NOT a 1XX or 2XX status code, throw Exception
            log('Response started');
            if (_onResponseStarted != null) {
              _onResponseStarted!(respCode);
            }
          }
          break;
        // Read a chunk of data.
        // This is where we actually read
        // the response from the server.
        //
        // Data gets added to the stream here.
        // ReadDataCallback is invoked here
        // with data received, no of bytes read
        // and a function which can be called
        // to continue reading.
        case 'OnReadCompleted':
          {
            final request = Pointer<Cronet_UrlRequest>.fromAddress(args[0]);
            final info = Pointer<Cronet_UrlResponseInfo>.fromAddress(args[1]);
            final buffer = Pointer<Cronet_Buffer>.fromAddress(args[2]);
            final bytesRead = args[3];

            log('Recieved: $bytesRead');
            final respCode = statusChecker(
                info,
                100,
                299,
                () => cleanUpRequest(reqPtr,
                    cleanUpClient)); // If NOT a 1XX or 2XX status code, throw Exception
            final data = cronet.Cronet_Buffer_GetData(buffer)
                .cast<Uint8>()
                .asTypedList(bytesRead);

            // invoke the callback
            if (_onReadData != null) {
              _onReadData!(data.toList(growable: false), bytesRead, respCode,
                  () {
                final res = cronet.Cronet_UrlRequest_Read(request, buffer);
                if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
                  cleanUpRequest(reqPtr, cleanUpClient);
                  _callBackCompleter!.completeError(UrlRequestException(res));
                }
              });
            } else {
              // or, add data to the stream
              _controller.sink.add(data.toList(growable: false));
              final res = cronet.Cronet_UrlRequest_Read(request, buffer);
              if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
                cleanUpRequest(reqPtr, cleanUpClient);
                _controller.addError(UrlRequestException(res));
                _controller.close();
              }
            }
          }
          break;
        // When there is any network error
        // We will shut everything down after this.
        case 'OnFailed':
          {
            final error =
                Pointer.fromAddress(args[0]).cast<Utf8>().toDartString();
            cleanUpRequest(reqPtr, cleanUpClient);
            if (_onFailed != null) {
              _onFailed!(HttpException(error));
              _callBackCompleter!.complete();
            }
            if (_onReadData == null) {
              // if callbacks are not registered, stream isn't closed before. So, close here.
              _controller.addError(HttpException(error));
              _controller.close();
            } else {
              // if callback is registed but onFailed callback is not
              _callBackCompleter!.completeError(HttpException(error));
            }
          }
          break;
        // when the request is cancelled
        // We will shut everything down after this.
        case 'OnCanceled':
          {
            cleanUpRequest(reqPtr, cleanUpClient);
            if (_onCanceled != null) {
              _onCanceled!();
            }
            if (_onReadData == null) {
              // if callbacks are not registered, stream isn't closed before. So, close here.
              _controller.close();
            } else {
              _callBackCompleter!.complete();
            }
          }
          break;
        // when the request is succesfully done
        // all the data has received.
        // We will shut everything down after this.
        case 'OnSucceeded':
          {
            cleanUpRequest(reqPtr, cleanUpClient);
            if (_onSuccess != null) {
              final respInfoPtr =
                  Pointer.fromAddress(args[0]).cast<Cronet_UrlResponseInfo>();
              _onSuccess!(cronet.Cronet_UrlResponseInfo_http_status_code_get(
                  respInfoPtr));
            }
            if (_onReadData == null) {
              // if callbacks are not registered, stream isn't closed before. So, close here.
              _controller.close();
            } else {
              _callBackCompleter!.complete();
            }
          }
          break;
        default:
          {
            break;
          }
      }
    }, onError: (Object error) {
      log(error.toString());
    });
  }
}
