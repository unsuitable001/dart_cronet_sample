export 'src/callback_handler.dart';
export 'src/generated_bindings.dart';


import 'dart:ffi';

import 'src/generated_bindings.dart';
final _cronet = Cronet(DynamicLibrary.open('../lib/src/wrapper/wrapper.so'));

Cronet get cronet => _cronet;

