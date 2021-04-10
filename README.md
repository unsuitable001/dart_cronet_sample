# dart_cronet_sample

A simple HTTP Client in Dart based on Cronet.

Ported from: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/

## Build Guide

Make sure you have `libcronet.so` file in path.

Follow: https://www.chromium.org/developers/how-tos/get-the-code & https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md for cronet's build instruction.


### Compile the wrapper

```
cd lib/src/wrapper
./build.sh
```

*Pre-compiled .so file is included in the repo. Build on 64-bit linux machine with Dart SDK 2.12*

## Usage Instruction

From the root of the repo, run

```
cd example
dart main.dart
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

```
cd benchmark
./benchmark.sh
```