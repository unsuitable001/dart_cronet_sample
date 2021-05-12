// Contains the nessesary setup code only. Not meant to be exposed.

import 'dart:io' show Process;

import 'find_resource.dart';

void buildWrapper() async {
  final wrapperPath = wrapperSourcePath();

  print('Building Wrapper...');
  var result = await Process.run(wrapperPath + '/build.sh', [wrapperPath]);
  print(result.stdout);
  print('Copying wrapper to project root...');
  result = await Process.run('cp', [wrapperPath + '/wrapper.so', '.']);
  print(result.stdout);
}
