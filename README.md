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

I compared this with `dart:io` library's http client. I ran tests 5 times, repeatitively (same machine, same network, same site). The results are given below -

```
Round 1:
Cronet implemenation took: 528 ms
dart:io implemenation took: 649 ms

Round 2:
Cronet implemenation took: 617 ms
dart:io implemenation took: 650 ms

Round 3:
Cronet implemenation took: 569 ms
dart:io implemenation took: 677 ms

Round 4:
Cronet implemenation took: 559 ms
dart:io implemenation took: 670 ms

Round 5:
Cronet implemenation took: 575 ms
dart:io implemenation took: 673 ms
```

### AOT Compilation

Though using AOT compilation reduced the execution time for both, this time `dart:io` based solution surpassed `cronet` based solution.

```
Round 1:
Cronet implemenation took: 487 ms
dart:io implemenation took: 479 ms

Round 2:
Cronet implemenation took: 500 ms
dart:io implemenation took: 483 ms

Round 3:
Cronet implemenation took: 493 ms
dart:io implemenation took: 482 ms

Round 4:
Cronet implemenation took: 497 ms
dart:io implemenation took: 500 ms

Round 5:
Cronet implemenation took: 486 ms
dart:io implemenation took: 462 ms
```

So, despite of the overhead of `dart:ffi` and the `wrapper` around it, even in this early stage, in such a small site, we can see cronet is faster. The differences **may** increase as we optimise some and test on a bigger load (& unstable network connection).

### Compare Yourself

```
cd benchmark
./benchmark.sh
```