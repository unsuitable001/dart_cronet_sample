# CMAKE file for windows build.

cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "cronet_sample")
project(${PROJECT_NAME} LANGUAGES C CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "wrapper")

add_compile_definitions(WIN32)
add_compile_definitions(DART_SHARED_LIB)


add_library(${PLUGIN_NAME} SHARED
  "wrapper.cc"
  "sample_executor.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/../include/dart/dart_api_dl.c"
)

# apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../include/dart"
  "${CMAKE_CURRENT_SOURCE_DIR}/../include/dart/runtime"
  "${CMAKE_CURRENT_SOURCE_DIR}/../include/cronet"

)

set(DART_DIR "C:/tools/dart-sdk/bin")
find_library(DART_LIB dart.lib ${DART_DIR})
target_link_libraries(${PLUGIN_NAME} PRIVATE ${DART_LIB})


set(MSVC_DISABLED_WARNINGS_LIST
  "C4152" # nonstandard extension, function/data pointer conversion in expression
  "C4255"
  "C4820"
  "C4255"
  "C4668"
)
string(REPLACE "C" " -wd" MSVC_DISABLED_WARNINGS_STR ${MSVC_DISABLED_WARNINGS_LIST})
set(CMAKE_C_FLAGS   "-utf-8 -Wall -WX ${MSVC_DISABLED_WARNINGS_STR}")