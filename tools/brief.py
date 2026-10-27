#!/usr/bin/env python3
"""One read per class: the generated header (ivars, method list) and the
x86_64 decompilation of each of the class's functions, without Ghidra's
local declarations, warnings and blank lines.

usage: brief.py <Target> <Class> [<Class>...]   e.g. brief.py SMKBitmapTools BTCGLayer
"""
import glob
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
target, classes = sys.argv[1], sys.argv[2:]
d = os.path.join(ROOT, 'analysis', 'decomp', target + '-x86_64')
rows = [l.rstrip('\n').split('\t') for l in open(os.path.join(d, 'index.tsv'))]
decl = re.compile(r'^\s+[A-Za-z_][\w ]*[\w*]\s+\*?[\w\[\]]+(\s*\[\w*\])?;$')
for cls in classes:
    # The class's @interface blocks (and its categories'), wherever they are.
    for h in sorted(glob.glob(os.path.join(ROOT, 'src', target, '*.h'))):
        text = open(h, errors='replace').read()
        for m in re.finditer(r'^@interface %s\b.*?^@end' % re.escape(cls), text, re.M | re.S):
            print('// ===== %s' % os.path.basename(h))
            print('\n'.join(l for l in m.group(0).splitlines() if l.strip()))
    for addr, size, name, file in rows:
        if name.split('::')[0] != cls and not name.startswith('objc::Categories::%s_' % cls):
            continue
        text = open(os.path.join(d, file)).read()
        if 'non-virtual thunk' in text[:300]:
            continue
        out = []
        for l in text.splitlines():
            if not l.strip() or decl.match(l) or 'WARNING' in l:
                continue
            out.append(l.rstrip())
        print('\n'.join(out))
