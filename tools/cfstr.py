#!/usr/bin/env python3
"""Finds the exact text of Ghidra's cfstr_* names: lists the binary's
constant CFStrings whose sanitized form matches each name (Ghidra replaces
every character that isn't a letter or digit with _).

usage: cfstr.py <Binary> <cfstr_name>...
"""
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
path = os.path.join(ROOT, 'analysis', sys.argv[1] + '-i386')
data = open(path, 'rb').read()
lines = subprocess.run(['otool', '-l', path], capture_output=True, text=True).stdout.splitlines()
segs, cfsec = [], None
for i, l in enumerate(lines):
    if l.strip() == 'cmd LC_SEGMENT':
        segs.append((int(lines[i + 3].split()[1], 16), int(lines[i + 4].split()[1], 16), int(lines[i + 5].split()[1])))
    if l.strip() == 'sectname __cfstring':
        cfsec = (int(lines[i + 2].split()[1], 16), int(lines[i + 3].split()[1], 16))


def rd(va, n):
    for s, vs, fo in segs:
        if s <= va < s + vs:
            return data[fo + va - s:fo + va - s + n]
    return b''


strings = []
for p in range(cfsec[0], cfsec[0] + cfsec[1], 16):
    isa, flags, ptr, length = struct.unpack('<4I', rd(p, 16))
    raw = rd(ptr, length * (2 if flags & 0x10 == 0 and flags != 0x7c8 else 1))
    try:
        s = raw[:length].decode('utf-8') if flags == 0x7c8 else raw.decode('utf-16-le')
    except UnicodeDecodeError:
        s = raw[:length].decode('latin-1')
    strings.append(s)
for name in sys.argv[2:]:
    key = name[len('cfstr_'):] if name.startswith('cfstr_') else name
    hits = [s for s in strings if re.sub(r'[^A-Za-z0-9]', '_', s)[:len(key)] == key and
            (len(re.sub(r'[^A-Za-z0-9]', '_', s)) == len(key) or len(key) >= 30)]
    print('%s = %s' % (name, ' | '.join(repr(h) for h in hits) or '?'))
