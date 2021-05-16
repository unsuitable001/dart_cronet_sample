# dart_cronet_sample

A simple HTTP Client in Dart based on Cronet.

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
      ref: flutter_support

```

2. Run this from the `root` of your project

```bash
flutter pub get
flutter pub run cronet_sample <platform>
```

Two platforms are currently supported. `linux64` and `androidarm64-v8a`

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
./build.sh .
```

Copy the `wrapper` binary to your project's `root` folder. 
Copy the cronet's binary to the `cronet_binaries/<platform><arch>` folder from project's `root` folder.

*If you are in 64bit linux system, `cronet_binaries/<platform><arch>` will be `cronet_binaries/linux64`.*

## Run Example

From the root of the repo, run

```bash
cd example
flutter run
```
