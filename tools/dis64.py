#!/usr/bin/env python3
"""x86_64 disassembly of one function (from its address to the next symbol
or the next function in the decompile index), with RIP-relative double and
float constants resolved and jump tables decoded.

usage: dis64.py <Binary> <hexaddr> [<hexend>]   e.g. dis64.py SMKBitmapTools 163a
"""
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
name = sys.argv[1]
path = os.path.join(ROOT, 'analysis', name + '-x86_64')
data = open(path, 'rb').read()
start = int(sys.argv[2], 16)
if len(sys.argv) > 3:
    end = int(sys.argv[3], 16)
else:
    addrs = sorted(int(l.split('\t')[0], 16)
                   for l in open(os.path.join(ROOT, 'analysis', 'decomp', name + '-x86_64', 'index.tsv')))
    end = next((a for a in addrs if a > start), start + 0x1000)
segs = []
for l in subprocess.run(['otool', '-l', path], capture_output=True, text=True).stdout.split('Load command'):
    if 'LC_SEGMENT_64' in l:
        f = dict(re.findall(r'\n\s*(vmaddr|vmsize|fileoff) (\S+)', l))
        segs.append((int(f['vmaddr'], 16), int(f['vmsize'], 16), int(f['fileoff'])))

def vm2off(a):
    for va, vs, fo in segs:
        if va <= a < va + vs:
            return fo + a - va
    return None

def cstring_at(a):
    o = vm2off(a)
    if o is None:
        return None
    return data[o:data.index(b'\0', o)].decode('utf-8', 'replace')

def cfstring_at(a):
    o = vm2off(a)
    if o is None:
        return None
    isa, flags, ptr, length = struct.unpack('<QQQQ', data[o:o + 32])
    if flags & 0x10:  # UTF-16 contents (0x7d0; plain strings are 0x7c8)
        po = vm2off(ptr)
        return data[po:po + 2 * length].decode('utf-16-le', 'replace') if po is not None else None
    return cstring_at(ptr)

out = subprocess.run(['otool', '-tvV', path], capture_output=True, text=True).stdout.splitlines()
rows = []
for l in out:
    m = re.match(r'([0-9a-f]{16})\t(.*)', l)
    if m:
        a = int(m.group(1), 16)
        if start <= a < end:
            rows.append((a, m.group(2)))
for i, (a, text) in enumerate(rows):
    nxt = rows[i + 1][0] if i + 1 < len(rows) else end
    note = ''
    m = re.search(r'(-?0x[0-9a-f]+)\(%rip\)', text)
    if m and 'cfstring ref' in text:
        cf = cfstring_at(nxt + int(m.group(1), 16))
        if cf is not None:
            text = re.sub(r'## Objc cfstring ref: .*', '## @%s' % repr(cf), text)
    elif m and '##' not in text:
        target = nxt + int(m.group(1), 16)
        if target + 8 <= len(data):
            if re.match(r'(movsd|addsd|subsd|mulsd|divsd|ucomisd|comisd|maxsd|minsd|andpd|xorpd|orpd|movapd)', text):
                note = '  ; = %r' % struct.unpack('<d', data[target:target + 8])[0]
            elif re.match(r'(movss|addss|subss|mulss|divss|ucomiss|comiss)', text):
                note = '  ; = %r' % struct.unpack('<f', data[target:target + 4])[0]
            elif text.startswith('leaq'):
                # A jump table: entries relative to the table.
                j = i + 1
                if j + 3 < len(rows) and 'movslq' in ''.join(t for _, t in rows[j:j + 3]):
                    ents = []
                    k = 0
                    while k < 64:
                        v = struct.unpack('<i', data[target + 4 * k:target + 4 * k + 4])[0]
                        if not (start <= target + v < end):
                            break
                        ents.append('%d:%x' % (k, target + v))
                        k += 1
                    note = '  ; jump table ' + ' '.join(ents)
    print('%x\t%s%s' % (a, text, note))
