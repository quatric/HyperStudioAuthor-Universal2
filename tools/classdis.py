#!/usr/bin/env python3
"""Disassemble every x86_64 method of a class and annotate ivar offset loads.

usage: classdis.py <Binary> <Class> [hexaddr=name ...]

Each method starts with '== <selector>'. Lines that load a rip-relative ivar
offset (`movq 0x…(%rip), %reg`) get ';; @<target>' plus a name when one is
given as hexaddr=name. Name targets from the simple accessors (a getter's only
load is its ivar), then rerun with the names.
"""
import os, re, subprocess, sys

here = os.path.dirname(os.path.abspath(__file__))
binary, cls = sys.argv[1], sys.argv[2]
names = dict(a.split('=', 1) for a in sys.argv[3:])
index = os.path.join(here, '..', 'analysis', 'decomp', binary + '-x86_64', 'index.tsv')
rows = [l.rstrip('\n').split('\t') for l in open(index) if l.split('\t')[2].startswith(cls + '::')]
rows.sort(key=lambda r: int(r[0], 16))
for addr, size, name, _ in rows:
    start = int(addr, 16)
    out = subprocess.run([sys.executable, os.path.join(here, 'dis64.py'), binary, '%x' % start, '%x' % (start + int(size))],
                         capture_output=True, text=True).stdout.split('\n')
    print('== ' + name.split('::', 1)[1])
    for i, l in enumerate(out):
        m = re.match(r'([0-9a-f]+)\t(movq|leaq)\t(0x[0-9a-f]+)\(%rip\), (%\w+)$', l)
        if m:
            j = i + 1
            while j < len(out) and not re.match(r'[0-9a-f]+\t', out[j]):
                j += 1
            if j < len(out):
                t = int(out[j].split('\t')[0], 16) + int(m.group(3), 16)
                l += '   ;; @%x %s' % (t, names.get('%x' % t, ''))
        if l:
            print(l)
