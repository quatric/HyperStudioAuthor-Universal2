#!/usr/bin/env python3
"""A generated stub file without Ghidra's local declarations, stack-address
bookkeeping, warnings and blank lines, for reading the i386 decompilation of
what the x86_64 index lacks (category methods).

usage: stubview.py <file.m> [<selector substring>...]
"""
import re
import sys

decl = re.compile(r'^\s+[A-Za-z_][\w ]*[\w*]\s+\*?[\w\[\]]+(\s*\[\w*\])?;$')
noise = re.compile(r'puStack_\w+ = |uStack_\w+ = |local_\w+ = \(undefined\w* \*?\)0x[0-9a-f]+;$|WARNING')
text = open(sys.argv[1]).read()
want = sys.argv[2:]
out = []
for l in text.splitlines():
    if not l.strip() or decl.match(l) or noise.search(l):
        continue
    out.append(l.rstrip())
text = '\n'.join(out)
if want:
    blocks = re.split(r'(?=/\* --- i386 decompilation)', text)
    text = '\n'.join(b for b in blocks if any(w in b for w in want))
print(text)
