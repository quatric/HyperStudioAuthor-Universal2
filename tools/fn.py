#!/usr/bin/env python3
"""Prints the decompilation of plain C functions by name or address from
analysis/decomp/<Binary>-i386, without the blank lines and the bare local
declarations.

usage: fn.py <Binary> <name-or-address>...      e.g. fn.py SMKApplicationKit FUN_0001fca1
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
binary = sys.argv[1]
base = os.path.join(ROOT, 'analysis', 'decomp', binary + '-i386')
index = [l.rstrip('\n').split('\t') for l in open(os.path.join(base, 'index.tsv'))]
for want in sys.argv[2:]:
    w = want.lower().replace('fun_', '')
    for addr, size, name, f in index:
        if name == want or addr.lower().lstrip('0') == w.lstrip('0'):
            for line in open(os.path.join(base, f), errors='replace'):
                if not line.strip() or re.match(r'^  (undefined\d?|int|uint|id|SEL|NSZone|char|bool|byte|short|ushort|float|double|longlong|ulonglong)\s+\**[a-zA-Z_0-9]+(\s*\[\d+\])?;$', line):
                    continue
                sys.stdout.write(line)
            print()
            break
    else:
        print('// not found:', want)
