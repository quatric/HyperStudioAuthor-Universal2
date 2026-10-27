#!/usr/bin/env python3
"""Inserts the methods of a chunk file before the @end of a class implementation and declares the new ones in its header.

usage: addmeth.py <Class> <chunk.m>    (the class is looked up as src/*/<Class>.m; the chunk holds complete method definitions)
"""
import glob
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
cls, chunk = sys.argv[1], sys.argv[2]
impl = glob.glob(os.path.join(ROOT, 'src', '*', (sys.argv[3] if len(sys.argv) > 3 else cls) + '.m'))[0]
header = impl[:-1] + 'h'
body = open(chunk).read().rstrip() + '\n'
decls = []
for line in body.split('\n'):
    if re.match(r'^[-+] \(', line):
        decls.append(line.rstrip('{ ').rstrip() + ';')
text = open(impl).read()
start = text.index('@implementation %s\n' % cls)
end = text.index('\n@end', start)
text = text[:end].rstrip('\n') + '\n\n' + body + text[end:]
open(impl, 'w').write(text)
h = open(header).read()
hs = h.index('@interface %s ' % cls)
he = h.index('\n@end', hs)
existing = h[hs:he]


def key(d):
    d = re.sub(r'^([-+]) \([^)]*(?:\([^)]*\))?[^)]*\)\s*', r'\1 ', d)
    return re.sub(r'\s+', ' ', re.sub(r':\s*\([^)]*(?:\([^)]*\))?[^)]*\)\s*\w+', ':', d)).strip(';').strip()


have = {key(l) for l in existing.split('\n') if re.match(r'^[-+] \(', l)}
new = [d for d in decls if key(d) not in have]
h = h[:he].rstrip('\n') + '\n' + '\n'.join(new) + h[he:]
open(header, 'w').write(h)
print('added', len(decls), 'methods,', len(new), 'new declarations')
