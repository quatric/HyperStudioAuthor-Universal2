#!/usr/bin/env python3
"""Prints the exported NSString/CFString constants of an i386 binary (data
symbols that point at a CFString) as Objective-C definitions.

usage: exported_strings.py <Binary>
"""
import os
import struct
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
name = sys.argv[1]
path = os.path.join(ROOT, 'analysis', name + '-i386')
data = open(path, 'rb').read()
lines = subprocess.run(['otool', '-arch', 'i386', '-l', path], capture_output=True, text=True).stdout.splitlines()
segs = []
for i, l in enumerate(lines):
    if l.strip() == 'cmd LC_SEGMENT':
        segs.append((int(lines[i + 3].split()[1], 16), int(lines[i + 4].split()[1], 16), int(lines[i + 5].split()[1])))


def rd(va, n):
    for s, vs, fo in segs:
        if s <= va < s + vs:
            return data[fo + va - s:fo + va - s + n]
    return b''


def word(va):
    b = rd(va, 4)
    return struct.unpack('<I', b)[0] if len(b) == 4 else None


def cstring(va):
    out = b''
    while True:
        c = rd(va + len(out), 1)
        if not c or c == b'\0':
            return out.decode('utf-8', 'replace')
        out += c


syms = subprocess.run(['nm', '-arch', 'i386', '-gU', path], capture_output=True, text=True).stdout.splitlines()
for l in syms:
    a, t, sym = l.split()
    if t not in 'SD':
        continue
    p = word(int(a, 16))
    if p is None:
        continue
    isa, flags, s, n = (word(p + 4 * k) for k in range(4))
    if flags in (0x7c8, 0x7d0) and s and n is not None and n < 4096:
        text = cstring(s)
        if len(text) == n:
            print('NSString * const %s = @"%s";' % (sym[1:], text.replace('\\', '\\\\').replace('"', '\\"')))
