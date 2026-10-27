#!/usr/bin/env python3
"""Who refers to a function that nothing calls: finds the function's address
stored as a pointer in the i386 binary's data (callback structs, method
lists, mod_init/term_func tables), names the section, and lists the code that
uses the word or the struct around it (any instruction mentioning an address
from 32 bytes before to 4 after, or a PIC-relative operand resolving there).

usage: xref.py <Binary> <FUN_xxx|hexaddr>...
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

sects = []  # (segname, sectname, addr, size, offset)
lines = subprocess.run(['otool', '-l', path], capture_output=True, text=True).stdout.splitlines()
for i, l in enumerate(lines):
    if l.strip().startswith('sectname'):
        g = lambda k: lines[i + k].split()[1]
        sects.append((g(1), l.split()[1], int(g(2), 16), int(g(3), 16), int(g(4))))

funcs = []
for l in open(os.path.join(ROOT, 'analysis', 'decomp', name + '-i386', 'index.tsv')):
    a, s, f, _ = l.split('\t')
    funcs.append((int(a, 16), int(s), f))
funcs.sort()


def func_at(va):
    lo, hi = 0, len(funcs)
    while lo < hi:
        mid = (lo + hi) // 2
        if funcs[mid][0] <= va:
            lo = mid + 1
        else:
            hi = mid
    if lo and funcs[lo - 1][0] <= va < funcs[lo - 1][0] + max(funcs[lo - 1][1], 1):
        return funcs[lo - 1][2]
    return '?'


dis = subprocess.run(['otool', '-tvV', path], capture_output=True, text=True).stdout.splitlines()

for want in sys.argv[2:]:
    addr = int(want.lower().replace('fun_', ''), 16)
    word = struct.pack('<I', addr)
    print('== %s (%x)' % (want, addr))
    found = False
    for seg, sect, s_addr, s_size, off in sects:
        if seg == '__TEXT' and sect == '__text':
            continue
        blob = data[off:off + s_size]
        i = blob.find(word)
        while i >= 0:
            if i % 4 == 0:
                found = True
                va = s_addr + i
                print('  stored at %x in %s,%s' % (va, seg, sect))
                if sect in ('__mod_init_func', '__constructor'):
                    print('    (static initializer)')
                elif sect in ('__mod_term_func', '__destructor'):
                    print('    (static destructor)')
                else:
                    targets = {'%x' % (va + d) for d in range(-32, 5, 4)}
                    users = set()
                    for l in dis:
                        m = re.match(r'([0-9a-f]{8})\s', l)
                        if not m:
                            continue
                        for t in targets:
                            if ('0x' + t) in l:
                                users.add(func_at(int(m.group(1), 16)))
                    print('    used by: %s' % (' '.join(sorted(users)) or 'nothing found (PIC offset: try dis.py)'))
            i = blob.find(word, i + 1)
    if not found:
        print('  not stored anywhere (dead, or reached through a computed address)')
