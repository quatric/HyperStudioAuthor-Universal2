#!/usr/bin/env python3
"""Prints the decompiles of the selectors of a class the sources do not implement yet.

usage: dump.py <Image> <Class> [<offset> <count>]   (instance and class methods, in the order missing.py lists them)
"""
import os
import re
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
image, cls = sys.argv[1], sys.argv[2]
out = subprocess.run([sys.executable, os.path.join(ROOT, 'tools', 'missing.py'), '-v', image], capture_output=True, text=True, cwd=ROOT).stdout.splitlines()
sels = []
for i, line in enumerate(out):
    m = re.match(r'\s*\d+ %s (\S+) (\S)$' % image, line)
    if m and m.group(1) == cls:
        kind = m.group(2)
        sels += [(kind, s) for s in out[i + 1].split()]
off = int(sys.argv[3]) if len(sys.argv) > 3 else 0
cnt = int(sys.argv[4]) if len(sys.argv) > 4 else len(sels)
d = os.path.join(ROOT, 'analysis', 'decomp', image + '-i386')
for kind, s in sels[off:off + cnt]:
    f = os.path.join(d, '%s[%s_%s].c' % (kind, cls, s.replace(':', '_')))
    if not os.path.exists(f):
        print('// no decompile for', kind, s)
        continue
    body = open(f, errors='ignore').read()
    body = re.sub(r'\n\s*\n', '\n', body)
    body = re.sub(r'\n\s*(undefined\d?|id|int|uint|char|SEL|bool|BOOL|double|float|ushort|long|byte|longlong|ulonglong|float10|undefined\d|HS\w+ \*|NS\w+ \*) ?\**[a-zA-Z_0-9\[\]]+;', '', body)
    body = re.sub(r'\n\s*(HSAnimationSetupMainAssistantPane \*local_\w+|undefined \*local_\w+);', '', body)
    print(body)
