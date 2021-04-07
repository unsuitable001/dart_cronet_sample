if [ ! -f "../example/main.exe" ]; then
    dart compile exe ../example/main.dart
fi

if [ ! -f "http_based.exe" ]; then
    dart compile exe http_based.dart
fi

echo "Let's check execution time of cronet's implementation"

../example/main.exe

echo "Let's check execution time of dart:io"

./http_based.exe
