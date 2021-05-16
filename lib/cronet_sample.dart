import 'dart:async';

import 'package:flutter/services.dart';

export 'standalone.dart';

class CronetSample {
  static const MethodChannel _channel = MethodChannel('cronet_sample');

  static Future<String> get platformVersion async {
    // ignore: omit_local_variable_types
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
