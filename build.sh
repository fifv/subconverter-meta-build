#!/usr/bin/env bash

# Set base and distribution directories
BASEDIR=$(dirname $(realpath $0))
# or BASEDIR=$PWD
DISTDIR=$BASEDIR/dist
# or DISTDIR=$HOME/Craft/subconverter-meta-build/dist

# Create a local installation directory
mkdir -p $DISTDIR

### Notes
# 1. re-cmake with new -DCMAKE_INSTALL_PREFIX= takes effect
# 2. 
###

# # Install mbedtls failed
# git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/Mbed-TLS/mbedtls
# cd mbedtls
# cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_INSTALL_PREFIX=$DISTDIR 
# cmake --build build --config Release --target install
# cd ..

# Install curl
git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/curl/curl --branch curl-8_17_0
cd curl
cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_INSTALL_PREFIX=$DISTDIR -DHTTP_ONLY=ON -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF -DCURL_USE_LIBSSH2=ON -DBUILD_CURL_EXE=OFF -DUSE_NGHTTP2=ON -DBUILD_LIBCURL_DOCS=OFF -DCURL_CA_BUNDLE=/etc/ssl/cert.pem -DCURL_CA_PATH=/etc/ssl/certs
cmake --build build --config Release --target install
cd ..

# Install yaml-cpp    yaml-cpp master break subconverter 0.9.2
git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/jbeder/yaml-cpp --branch yaml-cpp-0.9.0
cd yaml-cpp
cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_INSTALL_PREFIX=$DISTDIR -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF
cmake --build build --config Release --target install
cd ..

# Install quickjspp
git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/ftk/quickjspp
cd quickjspp
cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_INSTALL_PREFIX=$DISTDIR
cmake --build build --config Release --target quickjs
install -d $DISTDIR/lib/quickjs/
install -m644 build/quickjs/Release/libquickjs.a $DISTDIR/lib/quickjs/
install -d $DISTDIR/include/quickjs/
install -m644 quickjs/quickjs.h quickjs/quickjs-libc.h $DISTDIR/include/quickjs/
install -m644 quickjspp.hpp $DISTDIR/include/
cd ..

# Install libcron
git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/PerMalmberg/libcron
cd libcron
git submodule update --init
cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_INSTALL_PREFIX=$DISTDIR
cmake --build build --config Release --target libcron --target install
cd ..

# Install toml11
git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/ToruNiina/toml11 --branch="v4.3.0"
cd toml11
cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_INSTALL_PREFIX=$DISTDIR -DCMAKE_CXX_STANDARD=11
cmake --build build --config Release --target install
cd ..

# # Install rapidjson # SHIT , failed to compile
# git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/Tencent/rapidjson
# cd rapidjson
# cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_INSTALL_PREFIX=$DISTDIR -DCMAKE_POLICY_VERSION_MINIMUM=3.5
# cmake --build build --config Release --target install
# cd ..

# Final build
export PKG_CONFIG_PATH=$DISTDIR/lib64/pkgconfig
export CMAKE_PREFIX_PATH=$DISTDIR
# export CMAKE_INCLUDE_PATH=$DISTDIR/include
# export CMAKE_LIBRARY_PATH=$DISTDIR/lib
git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules https://github.com/MetaCubeX/subconverter
cd subconverter
cmake -S. -Bbuild -G"Ninja Multi-Config" -DCMAKE_PREFIX_PATH=$DISTDIR -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --config Release --target all








# Clean up
rm subconverter

# Compile the final executable
g++ -o base/subconverter $(find build/CMakeFiles/subconverter.dir/Release/src/ -name "*.o") -L$DISTDIR/lib -static -lpcre2-8 -lyaml-cpp -L$DISTDIR/lib64 -lcurl -lmbedtls -lmbedcrypto -lmbedx509 -lz -l:$DISTDIR/lib/quickjs/libquickjs.a -llibcron -O3 -s
