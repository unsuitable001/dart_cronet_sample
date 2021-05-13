# dart_cronet_sample

A simple HTTP Client in Dart based on Cronet.

Ported from: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/

[![Build Status](https://github.com/unsuitable001/dart_cronet_sample/workflows/Dart%20CI/badge.svg)](https://github.com/unsuitable001/dart_cronet_sample/actions?query=workflow%3A"Dart+CI")

Checkout the Flutter version with Android support: https://github.com/unsuitable001/flutter_cronet_sample

## Usage

1. Add this to `pubspec.yaml`

```
dependencies:
  cronet_sample:
    git: https://github.com/unsuitable001/dart_cronet_sample.git
```

2. Run this from the `root` of your project

```
pub get
pub run cronet_sample
```

**Internet connection is required to download cronet binaries**


## Build Guide

Want to build your own?

For building cronet: https://www.chromium.org/developers/how-tos/get-the-code & https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md

For building wrapper:

From this repository root

```
cd lib/src/native/wrapper
./build.sh .
```

Copy the `wrapper` binary to your project's `root` folder. 
Copy the cronet's binary to the `cronet_binaries/<platform><arch>` folder from project's `root` folder.

*If you are in 64bit linux system, `cronet_binaries/<platform><arch>` will be `cronet_binaries/linux64`.*

## Run Example

From the root of the repo, run

```
dart run
dart example/main.dart
```

### Output

You'll get the HTML page of `example.com` along with some other texts (I used them for lazy & easy debugging).


![example.com output](/output.png?raw=true "Screenshot")

## Comparison

I compared this with `dart:io` library's http client. I ran tests 5 times, repeatitively (same machine, same network, same site - http://info.cern.ch/). The results are given below -

```
Round 1:
cronet implemenation took: 385 ms
dart:io implemenation took: 351 ms

Round 2:
cronet implemenation took: 382 ms
dart:io implemenation took: 345 ms

Round 3:
cronet implemenation took: 378 ms
dart:io implemenation took: 349 ms

Round 4:
cronet implemenation took: 385 ms
dart:io implemenation took: 363 ms

Round 5:
cronet implemenation took: 385 ms
dart:io implemenation took: 359 ms
```

Well, now `cronet` based solution is marginally slower than `dart:io`. Making the API similar to `dart:io` surely added some overhead, like - receiving message from C side and then forwarding that data to another stream.

### Compare Yourself

*Run from root of the project*

```
./benchmark/benchmark.sh 
```