# dart_cronet_sample

A simple HTTP Client in Dart based on Cronet. (Version: 86.0.4240.198)

Ported from: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/

[![Build Status](https://github.com/unsuitable001/dart_cronet_sample/workflows/Dart%20CI/badge.svg)](https://github.com/unsuitable001/dart_cronet_sample/actions?query=workflow%3A"Dart+CI")

~~Checkout the Flutter version with Android support: https://github.com/unsuitable001/flutter_cronet_sample~~

Flutter (Android/Linux) support is now merged in this repository.

## Usage

1. Add this to `pubspec.yaml`

```pubspec
dependencies:
  cronet_sample:
    git:
      url: https://github.com/unsuitable001/dart_cronet_sample.git

```

2. Run this from the `root` of your project

Desktop Platforms

```bash
pub get
pub run cronet_sample <platform>
```
Supported platforms: `linux64` and `windows64`


Mobile Platforms (Flutter)

```bash
flutter pub get
```
Binaries aren't checked into git. They will be published on pub though. Meanwhile,
they can be downloaded from `Releases` section.

3. Import

```dart
import 'package:cronet_sample/cronet_sample.dart';
```

**Internet connection is required to download cronet binaries**


## Example

```dart
  final client = HttpClient();
  client
      .getUrl(Uri.parse('http://info.cern.ch/'))
      .then((HttpClientRequest request) {
    /* The alternate API.
    NOTE: If we register callbacks & listen to the stream at the same time,
    the stream will be closed immediately executing the onDone callback */

    // request.registerCallbacks(onReadData: (contents, size, next) {
    //   print(utf8.decoder.convert(contents));
    //   next();
    // }, onSuccess: () => print("Done!"));

    return request.close();
  }).then((Stream<List<int>> response) {
    response.transform(utf8.decoder).listen((contents) {
      print(contents);
    },
      onDone: () => print(
        'Done!'));
  });
```

## Build Guide

Want to build your own?

For building cronet: https://www.chromium.org/developers/how-tos/get-the-code & https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md

For building wrapper:

From this repository root

```bash
cd lib/src/native/wrapper
./build.sh . '"cronet_version"'
```

Copy the `wrapper` binary to your project's `root` folder. 
Copy the cronet's binary to the `cronet_binaries/<platform><arch>` folder from project's `root` folder. (Except on Windows. There, everything will be on root dir only)

*If you are in 64bit linux system, `cronet_binaries/<platform><arch>` will be `cronet_binaries/linux64`.*

### Special instruction for Windows

Due to an issue (#10), I'm temporarily using this solution.

1. Uncomment windows: pluginClass from `pubspec.yaml`
2. Go to `example` and do a `flutter run`. If it crashes, let it be. We just want to trigger the build.
3. From `example` directory, go to `build\windows\plugins\cronet_sample\Debug` and there you will find `cronet_sample_plugin.dll`
4. Rename `cronet_sample_plugin.dll` to `wrapper.dll` and you got your wrapper.

If you also want to find `flutter_windows.dll`, it will be at `build\windows\runner\Debug` relative to `example` folder.

## Run Example

From the root of the repo, run

```bash
cd example
flutter run
```

or

```bash
cd example_dart
dart run
```
