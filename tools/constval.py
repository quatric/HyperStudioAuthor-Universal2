#!/usr/bin/env python3
"""Prints the CFString constants behind the data symbols of an i386 binary as Objective-C definitions.

usage: constval.py <Binary> <Symbol>...   (symbols without the leading underscore)
"""
import re
import subprocess
import sys

root = __file__.rsplit('/', 2)[0]
image = sys.argv[1]
nm = subprocess.run(['nm', '%s/analysis/%s-i386' % (root, image)], capture_output=True, text=True).stdout
for sym in sys.argv[2:]:
    m = re.search(r'^([0-9a-f]+) [A-Za-z] _%s$' % re.escape(sym), nm, re.M)
    if not m:
        print('// %s: no data symbol' % sym)
        continue
    addr = m.group(1)
    out = subprocess.run([sys.executable, root + '/tools/data.py', image, addr, '1'], capture_output=True, text=True).stdout.splitlines()
    cf = out[0].split()[1]
    out = subprocess.run([sys.executable, root + '/tools/data.py', image, cf, '3'], capture_output=True, text=True).stdout.splitlines()
    s = re.search(r"'(.*)'", out[2]) if len(out) > 2 else None
    if s:
        print('NSString * const %s = @"%s"; // %s' % (sym, s.group(1), addr))
    else:
        print('// %s: value is %s (%s)' % (sym, out[0:1], addr))
