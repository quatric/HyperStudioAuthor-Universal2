#!/usr/bin/env python3
"""Disassembles one function of an original i386 binary with its PIC-relative
operands resolved: selector and class references, CFStrings, float and double
literals, and imported symbols.

usage: dis.py [-a] <binary> '<-[Class method:]>|_function|<hex address>'   (-a: keep addresses, for jumps)
"""
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from peek import sections  # noqa: E402


def main():
    args = sys.argv[1:]
    with_addr = args[:1] == ['-a']
    if with_addr:
        args = args[1:]
    name, func = args[0], args[1]
    path = 'analysis/%s-i386' % name
    cache = 'build/%s-i386.s' % name
    if not os.path.exists(cache) or os.path.getmtime(cache) < os.path.getmtime(path):
        with open(cache, 'w') as f:
            subprocess.run(['otool', '-tV', path], stdout=f, check=True)
    data = open(path, 'rb').read()
    secs = sections(path)

    # imported symbol pointers
    imports = {}
    out = subprocess.run(['otool', '-Iv', path], capture_output=True, text=True).stdout
    for line in out.splitlines():
        m = re.match(r'\s*0x([0-9a-f]+)\s+\d+\s+(\S+)', line)
        if m:
            imports[int(m.group(1), 16)] = m.group(2)

    def find(addr):
        for s in secs:
            if s['addr'] <= addr < s['addr'] + s['size']:
                return s
        return None

    def read(addr, n):
        s = find(addr)
        if s is None or s['sect'] in ('__bss', '__common'):
            return None
        o = s['offset'] + addr - s['addr']
        return data[o:o + n]

    def cstring(addr):
        b = read(addr, 256)
        return b.split(b'\0')[0].decode('latin-1') if b else '?'

    def word(addr):
        b = read(addr, 4)
        return struct.unpack('<I', b)[0] if b and len(b) == 4 else None

    def describe(addr, is_load):
        s = find(addr)
        if s is None:
            return None
        sect = s['sect']
        if addr in imports:
            return imports[addr]
        if sect in ('__message_refs', '__selrefs'):
            return '@selector(%s)' % cstring(word(addr))
        if sect in ('__cls_refs', '__classrefs'):
            return 'class %s' % cstring(word(addr))
        if sect == '__cfstring':
            w = read(addr, 16)
            return '@"%s"' % cstring(struct.unpack('<I', w[8:12])[0])
        if sect == '__literal4':
            return '%gf' % struct.unpack('<f', read(addr, 4))[0]
        if sect == '__literal8':
            return '%r' % struct.unpack('<d', read(addr, 8))[0]
        if sect == '__cstring':
            return '"%s"' % cstring(addr)
        if sect == '__const' and s['segname'] == '__TEXT':
            fl = struct.unpack('<4f', read(addr, 16))
            return '__const %s' % ', '.join('%g' % v for v in fl)
        return '%s,%s %#x' % (s['segname'], sect, addr)

    lines = open(cache).read().split('\n')
    start = None
    body = []
    if re.match(r'^(0x)?[0-9a-fA-F]{5,8}$', func):
        # A stripped binary: the function at an address, as long as Ghidra's
        # index says.
        addr = int(func, 16)
        size = None
        index = 'analysis/decomp/%s-i386/index.tsv' % name
        if os.path.exists(index):
            for l in open(index):
                f = l.split('\t')
                if int(f[0], 16) == addr:
                    size = int(f[1])
        if os.environ.get('DIS_SIZE'):
            # Ghidra sometimes ends a function early (before jump-table cases).
            size = int(os.environ['DIS_SIZE'], 0)
        for l in lines:
            m = re.match(r'^([0-9a-f]{8})\t', l)
            if m:
                a = int(m.group(1), 16)
                if a == addr:
                    start = a
                if start is not None:
                    if a >= addr + (size or 0x10000) or (size is None and a > addr and 'ret' in body[-1:][0:1]):
                        break
                    body.append(l)
        if start is None:
            # otool lost sync on data in __text before it: disassemble just
            # this range.
            out = subprocess.run(['objdump', '-d', '--no-show-raw-insn', '--no-leading-headers',
                                  '--start-address=%#x' % addr, '--stop-address=%#x' % (addr + (size or 0x1000)),
                                  path], capture_output=True, text=True).stdout
            for l in out.splitlines():
                m = re.match(r'^\s*([0-9a-f]+):\s+(.*)$', l)
                if m:
                    start = addr
                    body.append('%08x\t%s' % (int(m.group(1), 16), m.group(2).strip()))
        if start is None:
            sys.exit('no function at %s' % func)
    else:
        for i, l in enumerate(lines):
            if l == func + ':' or l == '_' + func.lstrip('_') + ':' and func.startswith('_'):
                start = i
                break
        if start is None:
            sys.exit('no function %s' % func)
        for l in lines[start + 1:]:
            if re.match(r'^[-+_A-Za-z].*:$', l):
                break
            body.append(l)
    # The PIC base: %ebx from __i686.get_pc_thunk.bx, or any register popped
    # right after a call to the next instruction.
    ebx = None
    pic = 'ebx'
    for i, l in enumerate(body):
        if 'get_pc_thunk.bx' in l and i + 1 < len(body):
            ebx = int(body[i + 1].split('\t')[0], 16)
            break
        m = re.search(r'calll\s+0x([0-9a-f]+)', l)
        if m and i + 1 < len(body) and body[i + 1].startswith(m.group(1).rjust(8, '0')):
            m2 = re.search(r'popl\s+%(\w+)', body[i + 1])
            if m2:
                ebx = int(m.group(1), 16)
                pic = m2.group(1)
                break
    for l in body:
        parts = l.split('\t')
        note = ''
        m = re.search(r'(-?0x[0-9a-f]+)\(%' + pic + r'\)', l)
        if not m and ebx is not None:
            # The base reloaded into another register from its stack slot:
            # large offsets off any register.
            m = re.search(r'(0x[0-9a-f]{5,})\(%(?!ebp|esp)\w+\)', l)
        if m and ebx is not None:
            d = describe((ebx + int(m.group(1), 16)) & 0xffffffff, 'lea' not in l)
            if d:
                note = '  ; ' + d
        m = re.search(r'\$0x([0-9a-f]+)', l)
        if m and not note:
            v = int(m.group(1), 16)
            d = describe(v, False) if v > 0x10000 else None
            if d:
                note = '  ; ' + d
            elif 0x3a000000 <= v <= 0x4f000000:
                note = '  ; %gf' % struct.unpack('<f', struct.pack('<I', v))[0]
        print('\t'.join(parts[0 if with_addr else 1:]) + note if len(parts) > 1 else l)


if __name__ == '__main__':
    main()
