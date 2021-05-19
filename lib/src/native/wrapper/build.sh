# Takes the path to wrapper source code path & cronet version as parameter
if [ $# -le 1 ]
  then
    echo "Provide <dir> '\"<cronet_version>\"'"
    exit 2
fi
cd $1
g++ -DCRONET_VERSION=$2 -fPIC -rdynamic -shared -W -o wrapper.so wrapper.cc sample_executor.cc ../include/dart_api_dl.c -ldl -I../include/ -DDART_SHARED_LIB -fpermissive -Wl,-z,origin -Wl,-rpath,'$ORIGIN' -Wl,-rpath,'$ORIGIN/cronet_binaries/linux64/'
