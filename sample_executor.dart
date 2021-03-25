import 'dart:ffi';
import 'dart:isolate';
import 'generated_bindings.dart';


void _RunTasksInQueue(SendPort sendPort) {

  Cronet _cronet = Cronet(DynamicLibrary.open('cronet/libcronet.91.0.4456.0.so'));
  
  ReceivePort task_queue = ReceivePort();

  sendPort.send(task_queue.sendPort);

  task_queue.listen((task) {            // tried passing existing cronet obj. can't. closure error
    // if(_cronet == null && task is Cronet) {
    //   _cronet = task;
    // } else {
      _cronet.Cronet_Runnable_Run(task);
      _cronet.Cronet_Runnable_Destroy(task);
    // }
      

  });
}


class SampleExecutor {
  static Cronet? _cronet;
  late final Pointer<Cronet_Executor> _executor;

  late final ReceivePort _receivePort;

  static SendPort? _sendPort;

  Isolate? _isolate;



  SampleExecutor(Cronet cronet) {
    _cronet = cronet;
    if(_cronet == null) {
      throw "Please set the library through constructor";
    }
    _executor = _cronet!.Cronet_Executor_CreateWith(ExecuteFunc);
    _cronet!.Cronet_Executor_SetClientContext(_executor,
      _cronet!.Cronet_Executor_GetClientContext(_executor)
    );

    _receivePort = ReceivePort();
    Isolate.spawn(_RunTasksInQueue, _receivePort.sendPort).then((value) { 
      _isolate = value;
    _receivePort.first.then((value) {
      _sendPort = value;
    });
  });
  
  }


  void ShutDownExecutor() {


    _isolate?.kill(priority: Isolate.immediate);


  }

  static void _Execute(
    Pointer<Cronet_Executor> self,
    Pointer<Cronet_Runnable> runnable) {
      // _cronet?.Cronet_Runnable_Run(runnable);
      // _cronet?.Cronet_Runnable_Destroy(runnable);
      if(_sendPort != null) {
        _sendPort?.send(runnable);
      }
  }



  Pointer<NativeFunction<Cronet_Executor_ExecuteFunc>> get ExecuteFunc => Pointer.fromFunction(_Execute);
  Pointer<Cronet_Executor> get executor => _executor;


  
}