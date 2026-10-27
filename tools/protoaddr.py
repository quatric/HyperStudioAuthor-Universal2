#!/usr/bin/env python3
"""protoaddr.py <i386 binary> [hexaddr...]
Lists the (__OBJC,__protocol) entries of an i386 binary by address, so the
DAT_xxxxxxxx protocol references in Ghidra decompiles can be named."""
import re, struct, subprocess, sys

binary = sys.argv[1]
want = {int(a, 16) for a in sys.argv[2:]}
raw = open(binary, 'rb').read()

secs, cur = [], {}
for line in subprocess.run(['otool', '-l', binary], capture_output=True, text=True).stdout.split('\n'):
    line = line.strip()
    m = re.match(r'(addr|size|offset) (\S+)', line)
    if m:
        cur[m.group(1)] = int(m.group(2), 16) if m.group(1) != 'offset' else int(m.group(2))
    if line.startswith('align') and 'addr' in cur:
        secs.append(dict(cur))
        cur = {}

def cstr(a):
    for s in secs:
        if s['addr'] <= a < s['addr'] + s['size']:
            o = s['offset'] + a - s['addr']
            return raw[o:raw.index(b'\0', o)].decode()
    return '?'

lines = subprocess.run(['otool', '-s', '__OBJC', '__protocol', binary], capture_output=True, text=True).stdout.split('\n')[2:]
data, base = b'', None
for l in lines:
    p = l.split()
    if not p:
        continue
    if base is None:
        base = int(p[0], 16)
    data += bytes(int(x, 16) for x in p[1:])
for i in range(len(data) // 20):
    addr = base + i * 20
    if not want or addr in want:
        print('%x %s' % (addr, cstr(struct.unpack('<I', data[i * 20 + 4:i * 20 + 8])[0])))
