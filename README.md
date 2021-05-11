# dart_cronet_sample

A simple HTTP Client in Dart based on Cronet.

Ported from: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/

[![Build Status](https://github.com/unsuitable001/dart_cronet_sample/workflows/Dart%20CI/badge.svg)](https://github.com/unsuitable001/dart_cronet_sample/actions?query=workflow%3A"Dart+CI")

Checkout the Flutter version with Android support: https://github.com/unsuitable001/flutter_cronet_sample

## Build Guide

Make sure you have `libcronet.so` file in path.

Follow: https://www.chromium.org/developers/how-tos/get-the-code & https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md for cronet's build instruction.

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