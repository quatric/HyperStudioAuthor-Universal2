#!/usr/bin/env python3
"""Compares the function sizes of the selectors a class shares with the HS5 build (a changed size means a changed body).

usage: sizes.py <Image> <Class>...
"""
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
H5 = '/Volumes/SSD/larsen/HyperStudio5-Universal2'


def classes(base, image):
    r = {}
    for e in json.load(open(os.path.join(base, 'analysis', 'objc-%s.json' % image))):
        for c in e['classes']:
            r[c['name']] = c
    return r


def size(base, image, imp):
    f = os.path.join(base, 'analysis', 'decomp', image + '-i386', 'FUN_%s.c' % imp[2:])
    if not os.path.exists(f):
        return None
    m = re.search(r'(\d+) bytes', open(f, errors='ignore').readline())
    return int(m.group(1)) if m else None


def asize(image, kind, cls, sel):
    f = os.path.join(ROOT, 'analysis', 'decomp', image + '-i386', '%s[%s_%s].c' % (kind, cls, sel.replace(':', '_')))
    if not os.path.exists(f):
        return None
    m = re.search(r'(\d+) bytes', open(f, errors='ignore').readline())
    return int(m.group(1)) if m else None


image = sys.argv[1]
A = classes(ROOT, image)
B = classes(H5, image)
for n in sys.argv[2:]:
    for kind, key in (('-', 'imethods'), ('+', 'cmethods')):
        hs5 = {m['sel']: m['imp'] for m in B[n][key]}
        for m in A[n][key]:
            if m['sel'] in hs5:
                sa = asize(image, kind, n, m['sel'])
                sb = size(H5, image, hs5[m['sel']])
                if sa != sb:
                    print('%s%s %s: Author %s HS5 %s' % (kind, n, m['sel'], sa, sb))
