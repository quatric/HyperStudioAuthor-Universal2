#!/usr/bin/env python3
"""Prints the i386 Ghidra decompile of ObjC methods by name, from the objc
dump's imp addresses: method.py <Binary> '-[Class sel]'... (a trailing * on
the name matches every method that starts with it, e.g. '-[SMKGridMatrix *').
With --wg <dir> <objc.json> it also prints the other build's decompile."""
import json, os, sys
here = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
args = sys.argv[1:]
other = None
if args[0] == '--wg':
    other = (args[1], args[2]); args = args[3:]
binary, names = args[0], args[1:]
def load(p):
    out = {}
    for x in json.load(open(p)):
        for c in x['classes'] + x['categories']:
            n = c['name'] if 'class' not in c else c['class'] + '(' + c['name'] + ')'
            for k in ('imethods', 'cmethods'):
                for m in c.get(k) or []:
                    out[('-' if k == 'imethods' else '+') + '[' + n + ' ' + m['sel'] + ']'] = int(m['imp'], 16)
    return out
mine = load(os.path.join(here, 'analysis', 'objc-%s.json' % binary))
theirs = load(other[1]) if other else {}
def show(d, a):
    p = os.path.join(d, 'FUN_%08x.c' % a)
    print(open(p).read() if os.path.exists(p) else '(no decompile)')
for n in names:
    keys = [k for k in mine if k.startswith(n[:-1])] if n.endswith('*') else [n]
    for k in sorted(keys):
        print('=' * 8, k)
        show(os.path.join(here, 'analysis', 'decomp', binary + '-i386'), mine[k])
        if other and k in theirs:
            print('-' * 8, 'other build')
            show(other[0], theirs[k])
