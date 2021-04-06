g++ -fPIC -rdynamic -shared -W -o wrapper.so wrapper.cc sample_executor.cc /usr/lib/dart/include/dart_api_dl.c -ldl -I/usr/lib/dart/include/ -DDART_SHARED_LIB -fpermissive
