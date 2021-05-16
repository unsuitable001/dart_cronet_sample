import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cronet_sample/cronet_sample.dart';

void main() {
  const channel = MethodChannel('cronet_sample');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CronetSample.platformVersion, '42');
  });
}
