#!/bin/bash

EMSCRIPTEN_ROOT=/emsdk_portable/sdk
OUTPUT_PATH=/dist
SOURCE_PATH=/src
SYSROOT=$EMSCRIPTEN_ROOT/system
VJANSSON=2.12

echo "Fetching dependencies..."
cd $SOURCE_PATH
git clone --single-branch --branch master https://github.com/quiet/quiet.git
git clone --single-branch --branch devel https://github.com/quiet/quiet-dsp.git
git clone --single-branch --branch v$VJANSSON https://github.com/akheron/jansson.git


echo "Building dependencies..."
echo "Building libjansson"
pushd jansson
autoreconf -i
emconfigure ./configure
emmake make
cp src/.libs/libjansson.so $SYSROOT/bin
cp $SYSROOT/bin/libjansson.so $SYSROOT/bin/libjansson.bc
cp src/jansson.h $SYSROOT/include
cp src/jansson_config.h $SYSROOT/include
popd

pushd quiet-dsp
echo "Building libliquid"
./bootstrap.sh
emconfigure ./configure
emmake make
emcc $(find src/ -type f -name *.o) -o libliquid.bc
cp libliquid.bc $SYSROOT/bin/
cp $SYSROOT/bin/libliquid.bc $SYSROOT/bin/libliquid.a
mkdir $SYSROOT/include/liquid
cp include/liquid.h $SYSROOT/include/liquid
popd

echo "Building quiet..."
pushd quiet
sed -i.bak -e '62,71d' CMakeLists.txt
mkdir build
cd build
emconfigure cmake ..
sed -i.bak s/libliquid.a/libliquid.bc/g CMakeFiles/quiet.dir/linklibs.rsp
sed -i.bak s/libjansson.so/libjansson.bc/g CMakeFiles/quiet.dir/linklibs.rsp
emmake make
cd lib
emcc -v -Oz libquiet.so -o $OUTPUT_PATH/quiet.js \
    -s ASSERTIONS=1 \
    -s MODULARIZE=1 \
    -s EXPORT_NAME="'quiet'" \
    -s EXPORTED_FUNCTIONS="['_quiet_decoder_consume','_quiet_decoder_create', '_quiet_decoder_flush', '_quiet_decoder_recv', '_quiet_decoder_destroy', '_quiet_encoder_emit', '_quiet_encoder_create','_quiet_encoder_destroy', '_quiet_encoder_send', '_quiet_encoder_get_frame_len', '_quiet_encoder_profile_str', '_quiet_decoder_profile_str', '_quiet_encoder_clamp_frame_len', '_quiet_decoder_checksum_fails', '_quiet_decoder_enable_stats', '_quiet_decoder_disable_stats', '_quiet_decoder_consume_stats']"