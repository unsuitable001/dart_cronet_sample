// Contains code related to asset path resolution only. Not meant to be exposed.

import 'dart:convert';
import 'dart:io' show File, Directory;

Uri? _findPackageRoot() {
  var root = Directory.current.uri;
  do {
    // Traverse up till .dart_tool/package_config.json is found
    final file = File.fromUri(root.resolve('.dart_tool/package_config.json'));
    if (file.existsSync()) {
      // get package path from package_config
      try {
        final packageMap =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        if (packageMap['configVersion'] == 2) {
          var ffigenRootUriString = ((packageMap['packages'] as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .firstWhere((element) => element['name'] == 'cronet_sample')[
              'rootUri'] as String);
          ffigenRootUriString = ffigenRootUriString.endsWith('/')
              ? ffigenRootUriString
              : ffigenRootUriString + '/';
          return file.parent.uri.resolve(ffigenRootUriString);
        }
      } catch (e, s) {
        print(s);
        throw Exception('Cannot resolve package:cronet_sample\'s rootUri');
      }
    }
  } while (root != (root = root.resolve('..')));
  return null;
}

String wrapperSourcePath() {
  final packagePath = _findPackageRoot();
  if (packagePath == null) {
    throw Exception('Cannot resolve package:cronet_sample\'s rootUri');
  }
  final wrapperSource = packagePath.resolve('lib/src/native/wrapper');
  if (!Directory.fromUri(wrapperSource).existsSync()) {
    throw Exception('Cannot find wrapper source!');
  }
  return wrapperSource.toFilePath();
}
