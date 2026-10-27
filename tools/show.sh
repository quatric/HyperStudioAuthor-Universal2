#!/bin/sh
# prints cleaned Author decompiles: show.sh <Image> <Class> <selector-with-underscores>...
image=$1; cls=$2; shift 2
for s in "$@"; do
python3 - "$image" "$cls" "$s" <<'P'
import re,sys,os
image,cls,s=sys.argv[1:4]
root=os.path.dirname(os.path.abspath(sys.argv[0])) if False else '/Volumes/SSD/larsen/HyperStudioAuthor-Universal2'
for kind in '-+':
    f='%s/analysis/decomp/%s-i386/%s[%s_%s].c'%(root,image,kind,cls,s)
    if os.path.exists(f):
        t=open(f,errors='ignore').read()
        t=re.sub(r'\n\s*\n','\n',t)
        t=re.sub(r'\n\s*(undefined\d?|id|int|uint|char|SEL|bool|BOOL|double|float|ushort|long|byte|longlong|ulonglong|undefined4|undefined1) \**[a-zA-Z_0-9\[\]]+;','',t)
        t=re.sub(r'\n\s*(HS\w+|NS\w+) \*\w+;','',t)
        t=re.sub(r'\n\s*local_\w+ = PTR_s_\w+;','',t)
        print(t)
P
done
