#!/usr/bin/env python3
"""Condensed view of skeleton files for translating: the ivars from the
header, then each untranslated method's decompilation (without blank lines
and bare local declarations) followed by its declaration.

usage: view.py <file.m>... [-o out.txt]
"""
import re
import sys

DECL = re.compile(r'^  (undefined\d*|int|uint|id|SEL|NSZone|char|bool|byte|short|ushort|float|double|'
                  r'longlong|ulonglong|BOOL|Class|CGFloat|NSRect|NSPoint|NSSize|CGRect|CGPoint|CGSize|'
                  r'NSRange|[A-Za-z_0-9]+_anon\d+|anon_[0-9a-f_]+|struct [A-Za-z_0-9]+)\s+\**[a-zA-Z_0-9]+'
                  r'(\s*\[\d+\])?;$')
args = sys.argv[1:]
out = sys.stdout
if '-o' in args:
    i = args.index('-o')
    out = open(args[i + 1], 'w')
    args = args[:i] + args[i + 2:]
for path in args:
    out.write('######## %s\n' % path)
    h = path[:-2] + '.h'
    try:
        hdr = open(h).read()
        for m in re.finditer(r'@interface (\w+) : (\w+).*?\{\n(.*?)\}', hdr, re.S):
            out.write('// %s : %s ivars: %s\n' % (m.group(1), m.group(2),
                      ' '.join(l.strip() for l in m.group(3).splitlines())))
    except OSError:
        pass
    text = open(path).read()
    ivo = re.findall(r'/\* i386 ivar offsets: (.*?) \*/', text)
    for o in ivo:
        out.write('// offsets: %s\n' % o)
    for line in text.splitlines():
        if not line.strip() or DECL.match(line) or line.startswith('/* --- i386'):
            continue
        if line == '*/' or line.startswith('    HS_UNTRANSLATED') or line.startswith('    return 0;') \
                or line.startswith('    return (') or line.startswith('#import'):
            continue
        out.write(line + '\n')
