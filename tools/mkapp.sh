#!/bin/sh
# Assembles build/HyperStudio Author.app from build/bin plus the original resources in game/.
# Install names in the built frameworks fix their Versions/<x> directory (see the Makefile).
set -e
P=$(cd "$(dirname "$0")/.." && pwd); O="$P/game/Contents"
APP="$P/build/HyperStudio Author.app"; A="$APP/Contents"; rm -rf "$APP"; mkdir -p "$A/MacOS" "$A/Frameworks"
EXE=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" "$O/Info.plist")
cp "$P/build/bin/HyperStudio" "$A/MacOS/$EXE"
cp "$O/Info.plist" "$O/PkgInfo" "$A/"
ln -s "$O/Resources" "$A/Resources"; [ -d "$O/PlugIns" ] && ln -s "$O/PlugIns" "$A/PlugIns"
[ -d "$O/Library" ] && ln -s "$O/Library" "$A/Library"
for n in HyperEditorBase:A HyperPlayerBase:A SMKApplicationKit:C-10-4 SMKBitmapTools:A-10-4 SMKCheckForUpdates:B SMKControls:A SMKPublish:A HSQTKit:A; do
  name=${n%%:*}; v=${n##*:}; f="$O/Frameworks/$name.framework"; F="$A/Frameworks/$name.framework"; d="$F/Versions/$v"
  mkdir -p "$d"; ln -s "$v" "$F/Versions/Current"
  cp "$P/build/bin/$name" "$d/$name"
  ov=$(readlink "$f/Versions/Current" 2>/dev/null || true)
  [ -n "$ov" ] && [ -d "$f/Versions/$ov/Resources" ] && ln -s "$f/Versions/$ov/Resources" "$d/Resources"
  ln -s "Versions/Current/$name" "$F/$name"; [ -d "$d/Resources" ] && ln -s Versions/Current/Resources "$F/Resources"
  ln -sfn ../.. "$F/Versions/Frameworks"
done
install_name_tool -add_rpath @executable_path/../Frameworks "$A/MacOS/$EXE" 2>/dev/null || true
for b in "$A/MacOS/$EXE" "$A"/Frameworks/*/Versions/*/*; do [ -f "$b" ] && [ ! -L "$b" ] && codesign -f -s - "$b" 2>/dev/null || true; done
echo "$APP"
