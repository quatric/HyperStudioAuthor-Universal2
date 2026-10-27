#!/usr/bin/env python3
"""Dumps 32-bit words of an i386 binary at addresses, naming what they point
to: C strings, functions (from the decompile index), imported symbols (the
indirect symbol table: what Ghidra shows as PTR_xxxx).

usage: data.py <Binary> <address> [<words>] ...   e.g. data.py SMKApplicationKit 6b1e0 9 720a0
"""
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
name = sys.argv[1]
path = os.path.join(ROOT, 'analysis', name + '-i386')
data = open(path, 'rb').read()
lines = subprocess.run(['otool', '-l', path], capture_output=True, text=True).stdout.splitlines()
segs = []
for i, l in enumerate(lines):
    if l.strip() == 'cmd LC_SEGMENT':
        segs.append((int(lines[i + 3].split()[1], 16), int(lines[i + 4].split()[1], 16), int(lines[i + 5].split()[1])))
funcs = {}
idx = os.path.join(ROOT, 'analysis', 'decomp', name + '-i386', 'index.tsv')
for l in open(idx):
    a, s, f, _ = l.split('\t')
    funcs[int(a, 16)] = f
imports = {}
for l in subprocess.run(['otool', '-Iv', path], capture_output=True, text=True).stdout.splitlines():
    m = re.match(r'0x([0-9a-f]+)\s+\d+\s+(\S+)', l)
    if m:
        imports[int(m.group(1), 16)] = m.group(2)


def rd(va, n):
    for s, vs, fo in segs:
        if s <= va < s + vs:
            return data[fo + va - s:fo + va - s + n]
    return b''


def cstr(va):
    b = rd(va, 120).split(b'\0')[0]
    return b.decode('latin-1') if b and all(32 <= c < 127 or c in (9, 10) for c in b) else None


def describe(v):
    if v in funcs:
        return 'func ' + funcs[v]
    if v in imports:
        return 'import ' + imports[v]
    s = cstr(v) if v else None
    return repr(s) if s else ''


args = sys.argv[2:]
i = 0
while i < len(args):
    addr = int(args[i], 16)
    n = int(args[i + 1]) if i + 1 < len(args) and not re.search('[a-f]', args[i + 1]) and len(args[i + 1]) <= 3 else 1
    i += 2 if n != 1 or (i + 1 < len(args) and args[i + 1] == '1') else 1
    if addr in imports:
        print('%08x: import %s' % (addr, imports[addr]))
        continue
    for k in range(n):
        a = addr + 4 * k
        w = struct.unpack('<I', rd(a, 4))[0]
        print('%08x: %08x %s' % (a, w, describe(w)))
