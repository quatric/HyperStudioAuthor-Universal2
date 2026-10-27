#!/usr/bin/env python3
"""Removes method definitions (and the Ghidra comment blocks) from a source file.

usage: rmmeth.py <file> <Class> <selector>...   removes the selectors from @implementation <Class> (or only strips the comments without selectors)
"""
import re
import sys

path, cls, sels = sys.argv[1], sys.argv[2], set(sys.argv[3:])
text = open(path).read()
text = re.sub(r'/\* --- i386 decompilation \(Ghidra\) ---.*?\*/\n', '', text, flags=re.S)
lines = text.split('\n')
out = []
inside = False
skip = False
removed = set()
for line in lines:
    m = re.match(r'@implementation\s+(\w+)', line)
    if m:
        inside = m.group(1) == cls
    if inside and not skip and re.match(r'^[-+] \(', line):
        rest = re.sub(r'^[-+] \([^)]*(?:\([^)]*\))?[^)]*\)\s*', '', line)
        if ':' in rest:
            parts = re.findall(r'(\w*):\s*\([^)]*(?:\([^)]*\))?[^)]*\)\s*\w+', rest)
            sel = ''.join(p + ':' for p in parts)
        else:
            sel = rest.split()[0].rstrip('{;')
        if sel in sels:
            skip = True
            removed.add(sel)
    if skip:
        if line == '}':
            skip = False
        continue
    out.append(line)
text = '\n'.join(out)
text = re.sub(r'\n{3,}', '\n\n', text)
open(path, 'w').write(text)
missing = sels - removed
print('removed', len(removed), 'not found', sorted(missing))
