#!/usr/bin/env python3
"""Replaces one @implementation block of a generated stub file (stubs and
their decompilation comments) with a translated one read from stdin, which
must itself be a whole '@implementation ... @end' block.

usage: put_impl.py <file.m> '<Class>' | '<Class> (<Category>)'  < block.m
"""
import re
import sys

path, name = sys.argv[1], sys.argv[2]
text = open(path).read()
new = sys.stdin.read().strip('\n') + '\n'
pat = re.compile(r'^@implementation %s\s*\n.*?^@end\n' % re.escape(name).replace(r'\ ', r'\s*'), re.M | re.S)
m = pat.search(text)
if not m:
    sys.exit('no @implementation %s in %s' % (name, path))
open(path, 'w').write(text[:m.start()] + new + text[m.end():])
