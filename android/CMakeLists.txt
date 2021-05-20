cmake_minimum_required(VERSION 3.10)  # for example
project(flutter_cronet)
add_library(wrapper

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             "../lib/src/native/wrapper/wrapper.cc"
             "../lib/src/native/wrapper/wrapper.h"
             "../lib/src/native/wrapper/sample_executor.cc"
             "../lib/src/native/wrapper/sample_executor.h"
             "../lib/src/native/include/dart/dart_api_dl.c"
)

include_directories(../lib/src/native/include/dart/)

add_compile_options(-fPIC -ldl -rdynamic -DDART_SHARED_LIB -fpermissive)