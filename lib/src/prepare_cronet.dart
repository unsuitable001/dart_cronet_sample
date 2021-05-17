// Contains the nessesary setup code only. Not meant to be exposed.

import 'dart:io' show Directory, File, Process, ProcessStartMode;

// import 'package:path/path.dart';

import 'find_resource.dart';

final _release = '1.0.0';
final _cronetBinaryUrl =
    'https://github.com/unsuitable001/dart_cronet_sample/releases/download/$_release/';
final _cBinExtMap = {
  'linux64': '.tar.xz',
  // 'androidarm64-v8a': '.tar.xz',
};

/// Builds the [wrapper] shared library
/// according to [build.sh] file
void buildWrapper() {
  final wrapperPath = wrapperSourcePath();

  print('Building Wrapper...');
  var result = Process.runSync(wrapperPath + '/build.sh', [wrapperPath]);
  print(result.stdout);
  print(result.stderr);
  print('Copying wrapper to project root...');
  result = Process.runSync('cp', [wrapperPath + '/wrapper.so', '.']);
  print(result.stdout);
  print(result.stderr);
}

// Disabled - files included via .pubignore

/// Move binary files for mobiles. Currenly just [Android] is implemented
// void moveMobileBinaries(String platform) {
//   if (platform.startsWith('android')) {
//     final android = findPackageRoot()!.toFilePath() + 'android';

//     Directory(android + '/libs').createSync();

//     Directory('cronet_binaries/' + platform + '/libs')
//         .listSync()
//         .forEach((jar) {
//       if (jar is File) {
//         jar.renameSync(android + '/libs/' + basename(jar.path));
//       }
//     }); // move the extracted jars

//     Directory(android + '/src/main/jniLibs').createSync();

//     Directory(
//             'cronet_binaries/' + platform + '/' + platform.split('android')[1])
//         .listSync()
//         .forEach((cronet) {
//       if (cronet is File) {
//         Directory(android + '/src/main/jniLibs/' + platform.split('android')[1])
//             .createSync();

//         if (cronet is File) {
//           cronet.renameSync(android +
//               '/src/main/jniLibs/' +
//               platform.split('android')[1] +
//               '/' +
//               basename(cronet.path));
//         }
//       }
//     }); // move cronet binaries
//     Directory('cronet_binaries/$platform').deleteSync(recursive: true);
//   }
// }

/// Download [cronet] library
/// from Github Releases
Future<void> downloadCronetBinaries(String platform) async {
  if (!isCronetAvailable(platform)) {
    final fileName = platform + (_cBinExtMap[platform] ?? '');
    print('Downloading Cronet for $platform');
    final downloadUrl = _cronetBinaryUrl + fileName;
    final dProcess = await Process.start('wget',
        ['-c', '-q', '--show-progress', '--progress=bar:force', downloadUrl],
        mode: ProcessStartMode.inheritStdio);
    if (await dProcess.exitCode != 0) {
      throw Exception('Can\'t download. Check your network connection!');
    }
    print('Extracting Cronet for $platform');

    // Process.runSync('mkdir', ['-p', 'cronet_binaries']);
    Directory('cronet_binaries').createSync();

    // Do we have tar extraction capability
    // in dart's built-in libraries?
    final res =
        Process.runSync('tar', ['-xvf', fileName, '-C', 'cronet_binaries']);
    if (res.exitCode != 0) {
      throw Exception(
          'Can\'t unzip. Check if the downloaded file isn\'t corrupted');
    }
    print('Done! Cleaning up...');

    File(fileName).deleteSync();
    // if (platform.startsWith('android')) {
    //   print(platform);
    //   moveMobileBinaries(platform);
    // }
    print('Done! Cronet support for $platform is now available!');
  } else {
    print('Cronet $platform is already available. No need to download.');
  }
}
