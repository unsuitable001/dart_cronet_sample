import 'dart:io' show Platform, Process;

import 'package:path/path.dart' show dirname;

void main(List<String> arguments) async {
  print('Building Wrapper...');
  var result = await Process.run(dirname(Platform.script.path) + '/build.sh',
      [dirname(Platform.script.path) + '/common/wrapper']);
  print(result.stdout);
  print('Copying required files to project root...');
  result = await Process.run('cp',
      [dirname(Platform.script.path) + '/common/wrapper/wrapper.so', '.']);
  print(result.stdout);
}
