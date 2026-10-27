#!/usr/bin/env python3
"""Removes plain C functions from src/<Target>/<Target>Functions.m (the #if 0
list of untranslated decompilations) once they are translated elsewhere or
not needed, e.g. Tiger-only paths.

usage: drop_fn.py <Target> <name-or-address>...
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
target = sys.argv[1]
path = os.path.join(ROOT, 'src', target, target + 'Functions.m')
text = open(path).read()
missing = []
for want in sys.argv[2:]:
    w = want.lower().replace('fun_', '').lstrip('0')
    pat = re.compile(r'/\* --- i386 decompilation \(Ghidra\) ---\n/\* (\S+) @ ([0-9a-f]+),.*?\n\*/\n\n?', re.S)
    for m in pat.finditer(text):
        if m.group(1) == want or m.group(2).lstrip('0') == w:
            text = text[:m.start()] + text[m.end():]
            break
    else:
        missing.append(want)
open(path, 'w').write(text)
if missing:
    sys.exit('not in %s (the others were dropped): %s' % (path, ' '.join(missing)))
