#!/usr/bin/env python3
"""Writes src/<Target>/<Target>Protocols.h: every protocol an i386 (ObjC 1)
binary declares, with its adopted protocols and its required and optional
methods, from the __OBJC,__protocol and __protocol_ext sections.

ObjC 1 keeps a copy of a protocol in each module that uses it; the copies
are merged. Protocols the SDK or a dependency target already declares are
left out. Types are spelled as gen_skeleton.py spells them; structures the
prefix header doesn't define yet are defined here first.

The generated prefix declares each protocol empty (`@protocol P <NSObject>
@end`); this script turns those into forward declarations and imports the
protocols header at the end of the prefix, after the structures.

usage: gen_protocols.py <Binary> <Target> [<dependency-target> ...]
"""
import glob
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_skeleton  # noqa: E402

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
binary, target, deps = sys.argv[1], sys.argv[2], sys.argv[3:]
path = os.path.join(ROOT, 'analysis', binary + '-i386')
data = open(path, 'rb').read()
lc = subprocess.run(['otool', '-l', path], capture_output=True, text=True).stdout
secs = [(m.group(1), int(m.group(2), 16), int(m.group(3), 16), int(m.group(4)))
        for m in re.finditer(r'sectname (\S+)\n\s+segname \S+\n\s+addr (0x[0-9a-f]+)\n'
                             r'\s+size (0x[0-9a-f]+)\n\s+offset (\d+)', lc)]


def off(a):
    for _, s, z, o in secs:
        if s <= a < s + z:
            return o + a - s
    return None


def words(a, n):
    return struct.unpack_from('<%dI' % n, data, off(a))


def cstr(a):
    o = off(a)
    return data[o:data.index(b'\0', o)].decode('latin-1')


def methods(a):
    """[(sel, types)] of a method_description_list."""
    if not a or off(a) is None:
        return []
    n = words(a, 1)[0]
    return [(cstr(s), cstr(t)) for s, t in (words(a + 4 + 8 * i, 2) for i in range(n))]


def protocol_list(a):
    if not a or off(a) is None:
        return []
    _, n = words(a, 2)
    return [cstr(words(p, 2)[1]) for p in words(a + 8, n)]


# merge the copies
protos = {}     # name -> {'adopts': [], 'req': {sel: types}, 'opt': {...}, 'creq', 'copt'}
psec = next(s for s in secs if s[0] == '__protocol')
ext = next((s for s in secs if s[0] == '__protocol_ext'), None)
for a in range(psec[1], psec[1] + psec[2], 20):
    isa, name, plist, imeth, cmeth = words(a, 5)
    p = protos.setdefault(cstr(name), {'adopts': [], 'req': {}, 'opt': {}, 'creq': {}, 'copt': {}})
    for q in protocol_list(plist):
        if q not in p['adopts']:
            p['adopts'].append(q)
    p['req'].update(methods(imeth))
    p['creq'].update(methods(cmeth))
    if isa and ext and ext[1] <= isa < ext[1] + ext[2]:
        _, oimeth, ocmeth, _props = words(isa, 4)
        p['opt'].update(methods(oimeth))
        p['copt'].update(methods(ocmeth))

skip = gen_skeleton.sdk_protocols() | {n for n in protos if n.startswith(('IK', 'NS')) and
                                       n != 'NSMutableArrayWeightBehaviors'}
for d in deps:
    for h in glob.glob(os.path.join(ROOT, 'src', d, '*.h')):
        skip |= set(re.findall(r'^@protocol (\w+)\b(?!;)', open(h, errors='replace').read(), re.M))
own = sorted(n for n in protos if n not in skip)

# adopted protocols first
ordered, seen = [], set()


def visit(n):
    if n in seen or n not in own:
        return
    seen.add(n)
    for q in protos[n]['adopts']:
        visit(q)
    ordered.append(n)


for n in own:
    visit(n)

tdir = os.path.join(ROOT, 'src', target)
prefix_path = os.path.join(tdir, target + 'Prefix.h')
prefix = open(prefix_path).read()
defined = set(re.findall(r'^(?:struct|union) (\w+) \{', prefix, re.M))
types = gen_skeleton.Types(target)
body = []
for n in ordered:
    p = protos[n]
    adopts = ', '.join(p['adopts']) or 'NSObject'
    body.append('@protocol %s <%s>' % (n, adopts))
    for key, sign, label in (('req', False, None), ('creq', True, None),
                             ('opt', False, '@optional'), ('copt', True, '@optional')):
        if not p[key]:
            continue
        if label:
            body.append(label)
        for sel, enc in sorted(p[key].items()):
            decl, _ = gen_skeleton.declaration({'sel': sel, 'types': enc}, sign, types)
            body.append(decl + ';')
    body.append('@end\n')

out = ['// The protocols %s declares (gen_protocols.py), after the prefix\'s' % binary,
       '// structures; the prefix forward-declares them all.', '']
for sname in types.order:
    if sname not in defined:
        out.append(types.structs[sname])
out.append('')
out += body
header = target + 'Protocols.h'
with open(os.path.join(tdir, header), 'w') as f:
    f.write('\n'.join(out))

# prefix: empty definitions -> forward declarations, import at the end
prefix = re.sub(r'^@protocol (\w+) <NSObject>\n@end\n', r'@protocol \1;\n', prefix, flags=re.M)
fwd = set(re.findall(r'^@protocol (\w+);', prefix, re.M))
missing = [n for n in own if n not in fwd]
if missing:
    prefix = prefix.replace('\n@protocol ', '\n' + ''.join('@protocol %s;\n' % n for n in missing) +
                            '@protocol ', 1)
imp = '#import "%s"\n' % header
if imp not in prefix:
    prefix = prefix.rstrip('\n') + '\n\n' + imp
open(prefix_path, 'w').write(prefix)
print('%s: %d protocols written to %s (%d skipped), %d new structs'
      % (binary, len(ordered), header, len(protos) - len(ordered),
         len([s for s in types.order if s not in defined])))
