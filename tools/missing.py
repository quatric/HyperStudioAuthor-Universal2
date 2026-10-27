#!/usr/bin/env python3
"""Lists the selectors of the Author's Objective-C metadata that the sources do not implement.

usage: missing.py [<Image>...]   prints per class counts; -v lists the selectors
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
verbose = '-v' in sys.argv
images = [a for a in sys.argv[1:] if not a.startswith('-')] or ['HyperStudio', 'HyperEditorBase', 'HyperPlayerBase', 'SMKApplicationKit', 'SMKBitmapTools', 'SMKControls']
impl = re.compile(r'^@implementation\s+(\w+)')
meth = re.compile(r'^([-+])\s*\(([^)]*(?:\([^)]*\))?[^)]*)\)\s*(.*)$')


def selector(rest):
    rest = rest.strip()
    if rest.endswith('{'):
        rest = rest[:-1].strip()
    if rest.endswith(';'):
        rest = rest[:-1].strip()
    if ':' not in rest:
        return rest.split()[0] if rest else None
    parts = re.findall(r'(\w*):\s*\([^)]*(?:\([^)]*\))?[^)]*\)\s*\w+', rest)
    return ''.join(p + ':' for p in parts)


have = {}
for path in glob.glob(os.path.join(ROOT, 'src', '*', '*.m')):
    cls = None
    for line in open(path, errors='ignore'):
        m = impl.match(line)
        if m:
            cls = m.group(1)
            continue
        if line.startswith('@end'):
            cls = None
            continue
        if cls:
            m = meth.match(line)
            if m:
                s = selector(m.group(3))
                if s:
                    have.setdefault((cls, m.group(1)), set()).add(s)
total = 0
rows = []
for image in images:
    for img in json.load(open(os.path.join(ROOT, 'analysis', 'objc-%s.json' % image))):
        for c in img['classes']:
            for kind, sign in (('imethods', '-'), ('cmethods', '+')):
                want = {m['sel'] for m in c[kind]}
                miss = sorted(s for s in want - have.get((c['name'], sign), set()) if not s.startswith('.cxx'))
                if miss:
                    rows.append((len(miss), image, c['name'], sign, miss))
                    total += len(miss)
rows.sort(reverse=True)
for n, image, name, sign, miss in rows:
    print('%4d %s %s %s' % (n, image, name, sign))
    if verbose:
        print('     ' + ' '.join(miss))
print('total', total)
