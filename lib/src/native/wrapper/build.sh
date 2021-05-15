# Takes the path to wrapper source code as parameter
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 2
fi
cd $1
g++ -fPIC -rdynamic -shared -W -o wrapper.so wrapper.cc sample_executor.cc ../include/dart_api_dl.c -ldl -I../include/ -DDART_SHARED_LIB -fpermissive -Wl,-z,origin -Wl,-rpath,'$ORIGIN' -Wl,-rpath,'$ORIGIN/cronet_binaries/linux64/'
