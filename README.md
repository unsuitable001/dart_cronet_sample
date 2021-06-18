# dart_cronet_sample

A simple HTTP Client in Dart based on Cronet. (Version: 86.0.4240.198)

**Disclaimer:** This repository contains my experiments on binding cronet with dart.
More refined and reviewed code will be available at: [google/cronet.dart](https://github.com/google/cronet.dart) & [my fork of it](https://github.com/unsuitable001/cronet.dart).

Ported from: <https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/>

[![Build Status](https://github.com/unsuitable001/dart_cronet_sample/workflows/Dart%20CI/badge.svg)](https://github.com/unsuitable001/dart_cronet_sample/actions?query=workflow%3A"Dart+CI")

~~Checkout the Flutter version with Android support: <https://github.com/unsuitable001/flutter_cronet_sample>~~

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

   **Desktop Platforms**

   ```bash
   pub get
   pub run cronet_sample <platform>
   ```

   Supported platforms: `linux64` and `windows64`

   **Mobile Platforms (Flutter)**

   ```bash
   flutter pub get
   ```

    **Note:** Internet connection is required to download cronet binaries.

3. Import

   ```dart
   import 'package:cronet_sample/cronet_sample.dart';
   ```

## Example

```dart
  final client = HttpClient();
  client
      .getUrl(Uri.parse('http://info.cern.ch/'))
      .then((HttpClientRequest request) {
    return request.close();
  }).then((HttpClientResponse response) {
    response.transform(utf8.decoder).listen((contents) {
      print(contents);
    },
      onDone: () => print(
        'Done!'));
  });
```

### Alternate API

```dart
  final client = HttpClient();
  client
      .getUrl(Uri.parse('http://info.cern.ch/'))
      .then((HttpClientRequest request) {
    request.registerCallbacks((data, bytesRead, responseCode, next) {
      print(utf8.decoder.convert(data));
      print('Status: $responseCode');
      next();
    },
        onSuccess: (responseCode) =>
            print('Done with status: $responseCode')).catchError(
        (e) => print(e));
  });
```

## Build Guide

Want to build your own?

For building cronet: <https://www.chromium.org/developers/how-tos/get-the-code> & <https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md>

For building wrapper:

From this repository root

```bash
cd lib/src/native/wrapper
./build.sh . '"cronet_version"'
```

Copy the `wrapper` binary to your project's `root` folder.
Copy the cronet's binary to the `cronet_binaries/<platform><arch>` folder from project's `root` folder. (Except on Windows. There, everything will be on root dir only)

*If you are in 64bit linux system, `cronet_binaries/<platform><arch>` will be `cronet_binaries/linux64`.*

### For Windows

Required: Visual Studio 2019 with C++ Desktop Development tools.

1. Make sure that you have `cmake` for Visual Studio 2019 is available in your command line. If not, you should open something like `x64 Native Tools Command Prompt for VS 2019` from your start menu which will open a command prompt with required path set.

2. In the command prompt do -

   ```dosbatch
   cd <path_to_repo>\lib\src\native\wrapper
   cmake CMakeLists.txt -B out
   cmake --build out
   ```

3. From there, go to `out\Debug` folder to get `wrapper.dll`

## Run Example

From the root of the repo, run

```bash
cd example
flutter pub run cronet_sample <platform>
flutter run
```

or

```bash
cd example_dart
pub run cronet_sample <platform>
dart run
```

replace `<platform>` with `linux64`, `windows64` or `androidarm64-v8a`
