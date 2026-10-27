#!/usr/bin/env python3
"""Read constants from an x86_64 binary in analysis/ by VM address.

usage: rd64.py <Binary> <hexaddr> [count] [d|f|q|i]   (doubles by default)
"""
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
path = os.path.join(ROOT, 'analysis', sys.argv[1] + '-x86_64')
addr = int(sys.argv[2], 16)
count = int(sys.argv[3]) if len(sys.argv) > 3 else 1
kind = sys.argv[4] if len(sys.argv) > 4 else 'd'
data = open(path, 'rb').read()
segs = []
for l in subprocess.run(['otool', '-l', path], capture_output=True, text=True).stdout.split('Load command'):
    if 'LC_SEGMENT_64' in l:
        f = dict(re.findall(r'\n\s*(vmaddr|vmsize|fileoff) (\S+)', l))
        segs.append((int(f['vmaddr'], 16), int(f['vmsize'], 16), int(f['fileoff'])))
off = next(fo + addr - va for va, vs, fo in segs if va <= addr < va + vs)
size = struct.calcsize('<' + kind)
for i in range(count):
    print('%x\t%r' % (addr + i * size, struct.unpack_from('<' + kind, data, off + i * size)[0]))
