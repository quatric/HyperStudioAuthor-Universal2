#!/usr/bin/env python3
"""Names the protocol (or class/string) objects behind PTR_DAT_xxxx addresses.

usage: pr.py <Binary> <addr>...
"""
import subprocess
import sys

for a in sys.argv[2:]:
    out = subprocess.run([sys.executable, __file__.replace('pr.py', 'data.py'), sys.argv[1], a, '2'], capture_output=True, text=True).stdout.splitlines()
    print(a, out[1].split(None, 1)[1] if len(out) > 1 else out)
