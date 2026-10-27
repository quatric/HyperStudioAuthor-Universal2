#!/usr/bin/env python3
"""Lists the selectors that exist only in the Author (docs/delta.json) and
that src/ does not define yet, per class: missing_sel.py [Framework]."""
import collections, glob, json, re, sys
rep = json.load(open('docs/delta.json'))
for f, onlyA, onlyB, newm, gone, ivch in rep:
    if len(sys.argv) > 1 and f != sys.argv[1]:
        continue
    txt = collections.defaultdict(str)
    for p in glob.glob('src/%s/*.m' % f) + glob.glob('src/%s/*.mm' % f):
        s = open(p, errors='ignore').read()
        for m in re.finditer(r'@implementation\s+(\w+)', s):
            txt[m.group(1)] += s[m.end():s.find('\n@end', m.end())]
    miss = []
    for n, k, sel in newm:
        parts = sel.split(':')
        if len(parts) > 1:
            pat = r'^[-+]\s*\([^)]*\)\s*' + r'\s*:\s*\([^)]*\)\s*\w+\s+'.join(re.escape(x) for x in parts[:-1]) + r'\s*:'
        else:
            pat = r'^[-+]\s*\([^)]*\)\s*' + re.escape(sel) + r'\s*(\{|$)'
        if not re.search(pat, txt.get(n, ''), re.M):
            miss.append((n, k, sel))
    print('%s: %d new selectors, %d not defined yet' % (f, len(newm), len(miss)))
    for n, k, sel in miss:
        print('  %s[%s %s]' % ('-' if k == 'i' else '+', n, sel))
