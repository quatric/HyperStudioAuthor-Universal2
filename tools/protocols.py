#!/usr/bin/env python3
"""Protocol declarations from a binary's ObjC metadata (otool -oV): each
protocol's adopted protocols and its required and optional methods, with
the type encodings turned back into C types.

usage: protocols.py <Binary-arch> [<Protocol>...]   e.g. protocols.py SMKBitmapTools-x86_64 BTImage
"""
import os
import re
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(__file__), '..')
path = os.path.join(ROOT, 'analysis', sys.argv[1])
want = set(sys.argv[2:])
lines = subprocess.run(['otool', '-oV', path], capture_output=True, text=True).stdout.splitlines()

SIMPLE = {'@': 'id', 'v': 'void', 'c': 'BOOL', 'B': 'BOOL', 'C': 'unsigned char', 's': 'short',
          'S': 'unsigned short', 'i': 'int', 'I': 'unsigned int', 'l': 'int', 'L': 'unsigned int',
          'q': 'NSInteger', 'Q': 'NSUInteger', 'f': 'float', 'd': 'CGFloat', ':': 'SEL', '#': 'Class',
          '*': 'char *', '?': 'void *'}
STRUCTS = {'CGPoint': 'CGPoint', 'CGSize': 'CGSize', 'CGRect': 'CGRect', '_NSRange': 'NSRange',
           'CGAffineTransform': 'CGAffineTransform', '_NSZone': 'NSZone'}


def parse_type(s, i):
    """(C type, next index) for the encoding at s[i]."""
    quals = ''
    while s[i] in 'rnNoORV':
        if s[i] == 'r':
            quals = 'const '
        i += 1
    c = s[i]
    if c == '^':
        t, j = parse_type(s, i + 1)
        return quals + (t + '*' if t.endswith('*') else t + ' *'), j
    if c in '{(':
        close = '}' if c == '{' else ')'
        depth, j = 0, i
        while True:
            if s[j] in '{(':
                depth += 1
            elif s[j] in '})':
                depth -= 1
                if depth == 0:
                    break
            j += 1
        name = re.split(r'[=}]', s[i + 1:j + 1])[0]
        t = STRUCTS.get(name, ('struct ' if c == '{' else 'union ') + name)
        return quals + t, j + 1
    if c == '[':
        j = s.index(']', i)
        return 'void *', j + 1
    if c == '@' and i + 1 < len(s) and s[i + 1] == '"':
        j = s.index('"', i + 2)
        return 'id', j + 1
    if c == '@' and s[i + 1:i + 2] == '?':
        return 'id', i + 2
    return quals + SIMPLE.get(c, 'void *'), i + 1


def signature(sel, enc, cls):
    types = []
    i = 0
    while i < len(enc):
        t, i = parse_type(enc, i)
        while i < len(enc) and enc[i].isdigit():
            i += 1
        types.append(t)
    ret, args = types[0], types[3:]
    parts = sel.split(':')
    if not args:
        return '%s (%s)%s;' % (cls, ret, sel)
    out = []
    for k, a in enumerate(args):
        name = parts[k]
        words = re.findall(r'[A-Z]+(?![a-z])|[A-Z]?[a-z0-9]+', name) or ['arg%d' % k]
        arg = 'a' + words[-1][:1].upper() + words[-1][1:]
        n = 2
        while any(o.endswith(')' + arg) for o in out):
            arg = 'a' + words[-1][:1].upper() + words[-1][1:] + str(n)
            n += 1
        out.append('%s:(%s)%s' % (name, a, arg))
    return '%s (%s)%s;' % (cls, ret, ' '.join(out))


protos = {}
order = []
for i, l in enumerate(lines):
    m = re.match(r'^(\s*)name\s+0x[0-9a-f]+ (\w+)$', l)
    if not m or i + 1 >= len(lines) or not re.match(r'^\s*protocols\s', lines[i + 1]):
        continue
    indent, name = len(m.group(1)), m.group(2)
    if name in protos:
        continue
    adopted, methods, sect = [], [], None
    j = i + 1
    while j < len(lines):
        l2 = lines[j]
        ind = len(l2) - len(l2.lstrip())
        if ind < indent or (ind == indent and re.match(r'\s*(isa|name)\s', l2)):
            break
        if ind == indent:
            sect = l2.split()[0]
        elif sect == 'protocols' and ind == indent + 8:
            m2 = re.match(r'\s*name\s+0x[0-9a-f]+ (\w+)$', l2)
            if m2:
                adopted.append(m2.group(1))
        elif sect and 'Methods' in sect and ind == indent + 4:
            m2 = re.match(r'\s*name\s+0x[0-9a-f]+ (\S+)$', l2)
            if m2:
                enc = lines[j + 1].split()[-1]
                methods.append((sect, m2.group(1), enc))
        j += 1
    protos[name] = (adopted, methods)
    order.append(name)

done = {'NSObject', 'NSCoding', 'NSCopying', 'NSMutableCopying'}


def emit(name):
    if name in done or name not in protos:
        return
    done.add(name)
    for a in protos[name][0]:
        emit(a)
    print_proto(name)


def print_proto(name):
    adopted, methods = protos[name]
    print('@protocol %s%s' % (name, ' <%s>' % ', '.join(adopted) if adopted else ''))
    optional = False
    for sect, sel, enc in methods:
        opt = sect.startswith('optional')
        if opt != optional:
            print('@optional' if opt else '@required')
            optional = opt
        print(signature(sel, enc, '+' if 'class' in sect.lower() else '-'))
    print('@end')


for name in sorted(order):
    if want and name not in want or name == 'NSObject' or name.startswith('NS'):
        continue
    emit(name)
