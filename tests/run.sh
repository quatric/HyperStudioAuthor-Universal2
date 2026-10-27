#!/bin/sh
# Builds and runs a test program against build/bin: sh tests/run.sh gltest, or sh tests/run.sh qttest <out.mov>
# The dylibs' install names expect a Frameworks/ layout, so one is made with symlinks in build/test.
set -e
P=$(cd "$(dirname "$0")/.." && pwd); T=$P/build/test; F=$T/Frameworks
mkdir -p $T/bin "$F/SMKApplicationKit.framework/Versions/C-10-4" "$F/HSQTKit.framework/Versions/A" "$F/SMKBitmapTools.framework/Versions/A-10-4" "$F/SMKControls.framework/Versions/A"
ln -sf $P/build/bin/SMKApplicationKit "$F/SMKApplicationKit.framework/Versions/C-10-4/SMKApplicationKit"
ln -sf $P/build/bin/HSQTKit "$F/HSQTKit.framework/Versions/A/HSQTKit"
ln -sf $P/build/bin/SMKBitmapTools "$F/SMKBitmapTools.framework/Versions/A-10-4/SMKBitmapTools"
ln -sf $P/build/bin/SMKControls "$F/SMKControls.framework/Versions/A/SMKControls"
mkdir -p "$F/HyperPlayerBase.framework/Versions/A" "$F/SMKCheckForUpdates.framework/Versions/B"
ln -sf $P/build/bin/HyperPlayerBase "$F/HyperPlayerBase.framework/Versions/A/HyperPlayerBase"
ln -sf $P/build/bin/SMKCheckForUpdates "$F/SMKCheckForUpdates.framework/Versions/B/SMKCheckForUpdates"
# build/bin/SMKBitmapTools finds SMKApplicationKit at its own @loader_path/../Frameworks.
rm -f $P/build/Frameworks; ln -s $F $P/build/Frameworks
cd $T && clang -arch arm64 -fno-objc-arc -DGL_SILENCE_DEPRECATION -w -I$P/src/Common -I$P/src/HSQTKit -I$P/src/SMKApplicationKit -I$P/src/SMKBitmapTools -I$P/src/SMKControls \
  -include $P/src/SMKApplicationKit/SMKApplicationKitPrefix.h $P/tests/$1.m $P/build/bin/SMKApplicationKit $P/build/bin/HSQTKit $P/build/bin/SMKBitmapTools $P/build/bin/SMKControls $P/build/bin/HyperPlayerBase \
  -framework Cocoa -framework OpenGL -framework CoreVideo -framework AVFoundation -framework CoreMedia -framework VideoToolbox \
  -Wl,-rpath,@loader_path/../Frameworks -o bin/$1
N=$1; shift; cd $T && ./bin/$N "$@"
