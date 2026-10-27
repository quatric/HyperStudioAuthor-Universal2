#!/usr/bin/env python3
"""Counts the methods and functions left to translate in each target: ObjC
stubs (HS_UNTRANSLATED()), C++ worksheet blocks (/* UNTRANSLATED ...) and the
plain C functions still inside the #if 0 of <Target>Functions.m, against the
counts the generators started with (<target>/_count.txt)."""
import glob
import os
import re

ROOT = os.path.join(os.path.dirname(__file__), '..')
TARGETS = ['SMKApplicationKit', 'SMKBitmapTools', 'SMKControls', 'SMKPublish', 'HyperPlayerBase',
           'HyperEditorBase', 'HyperStudio']


def left_in(path):
    text = open(path, errors='replace').read()
    n = len(re.findall(r'HS_UNTRANSLATED\(\);', text)) + len(re.findall(r'^/\* UNTRANSLATED ', text, re.M))
    if path.endswith('Functions.m'):
        n += len(re.findall(r'^/\* --- i386 decompilation', text, re.M))
    return n


total_left = total = 0
for t in TARGETS:
    d = os.path.join(ROOT, 'src', t)
    files = [f for e in ('cpp', 'mm', 'm', 'c') for f in glob.glob(os.path.join(d, '*.' + e))]
    if not files:
        continue
    left = sum(left_in(f) for f in files)
    start = os.path.join(d, '_count.txt')
    n = int(open(start).read()) if os.path.exists(start) else left
    total_left += left
    total += n
    print('%-17s %5d / %5d translated, %5d left' % (t, n - left, n, left))
print('%-17s %5d / %5d translated, %5d left' % ('total', total - total_left, total, total_left))
