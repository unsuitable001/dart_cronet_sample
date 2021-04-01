# dart_cronet_sample

A simple HTTP Client in Dart based on Cronet.

Ported from: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/

## Build Guide

Make sure you have `libcronet.so` file in path.

Follow: https://www.chromium.org/developers/how-tos/get-the-code & https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md for cronet's build instruction.


### Compile the wrapper

```
cd wrapper
./build.sh
```

*Pre-compiled .so file is included in the repo. Build on 64-bit linux machine with Dart SDK 2.12*

## Usage Instruction

From the root of the repo, run

```
dart main.dart
```

### Output

You'll get the HTML page of `example.com` along with some other texts (I used them for lazy & easy debugging).


![example.com output](/output.png?raw=true "Screenshot")