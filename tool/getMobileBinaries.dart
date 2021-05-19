
import 'dart:io' show Directory, File;

import 'package:cronet_sample/src/prepare_cronet.dart';
import 'package:path/path.dart';

import 'package:cronet_sample/src/find_resource.dart';

/// Move binary files for mobiles. Currenly just [Android] is implemented
void placeMobileBinaries(String platform) {
  if (platform.startsWith('android')) {
    final android = findPackageRoot()!.toFilePath() + 'android';

    Directory(android + '/libs').createSync();

    Directory('cronet_binaries/' + platform + '/libs')
        .listSync()
        .forEach((jar) {
      if (jar is File) {
        jar.renameSync(android + '/libs/' + basename(jar.path));
      }
    }); // move the extracted jars

    Directory(android + '/src/main/jniLibs').createSync();

    Directory(
            'cronet_binaries/' + platform + '/' + platform.split('android')[1])
        .listSync()
        .forEach((cronet) {
      if (cronet is File) {
        Directory(android + '/src/main/jniLibs/' + platform.split('android')[1])
            .createSync();

        if (cronet is File) {
          cronet.renameSync(android +
              '/src/main/jniLibs/' +
              platform.split('android')[1] +
              '/' +
              basename(cronet.path));
        }
      }
    }); // move cronet binaries
    Directory('cronet_binaries/$platform').deleteSync(recursive: true);
  }
}


void main(List<String> platforms) {
  if(platforms.isEmpty) {
    print('Please provide list of platforms');
    return;
  }
  platforms.forEach((platform) async { 
    await downloadCronetBinaries(platform);
    placeMobileBinaries(platform);
  });
  
}