#!/usr/bin/env python3
"""Recovers the arguments Ghidra drops from an original i386 function.

Walks the disassembly (tools/dis.py -a) keeping a symbolic value for every
register, local and outgoing stack slot, and prints each Objective-C message
or C call with the values that were stored into its argument slots, plus the
comparisons in front of branches, arithmetic on the values and the branch
targets.  Straight-line reading of the output is usually enough to write the
method; branches are printed as they are (a label at every jump target).

usage: calltrace.py <Binary> <hex address | '-[Class sel]'> [-c Class]
       -c Class: name self's ivars from the i386 offsets comment of src/*/Class.m

Output notation: rN is the result of the Nth call, self/_cmd/p1.. are the
arguments, &Sym is the address of a global, Sym[+4] a field of it, "..." a
CFString, @sel(..) a selector, class X a class, imm 0x3f800000f= a float bit
pattern whose float value is shown after f=.
"""
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def split_ops(s):
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def fbits(v):
    try:
        f = struct.unpack('<f', struct.pack('<I', v & 0xffffffff))[0]
    except struct.error:
        return None
    if f != f or abs(f) > 1e12:
        return None
    return f


class Tracer:
    def __init__(self, binary, ivars):
        self.binary = binary
        self.ivars = ivars
        self.regs = {}
        self.slots = {}      # outgoing args: offset from esp -> (expr, width)
        self.locals = {}     # ebp offset -> expr
        self.ncall = 0
        self.lastcmp = None
        self.lastcall = None
        self.fp = []
        self.protos = {}
        self.out = []
        self.dataptrs = set()

    # ---- operand evaluation -------------------------------------------------
    def reg(self, r):
        r = r.lstrip('%')
        sub = {'al': 'eax', 'ax': 'eax', 'bl': 'ebx', 'cl': 'ecx', 'dl': 'edx', 'ah': 'eax', 'bh': 'ebx', 'ch': 'ecx', 'dh': 'edx'}
        return self.regs.get(sub.get(r, r), '<%s>' % r)

    def ann_expr(self, ann):
        if ann is None:
            return None
        ann = ann.strip()
        m = re.match(r'@selector\((.*)\)$', ann)
        if m:
            return '@sel(%s)' % m.group(1)
        m = re.match(r'class (\w+)$', ann)
        if m:
            return 'class %s' % m.group(1)
        if ann.startswith('@"'):
            return ann[1:]
        m = re.match(r'__OBJC,__protocol 0x([0-9a-f]+)$', ann)
        if m:
            self.protos[m.group(1)] = None
            return '@protocol(%s)' % m.group(1)
        m = re.match(r'__DATA,__nl_symbol_ptr 0x([0-9a-f]+)$', ann)
        if m:
            self.dataptrs.add(m.group(1))
            return '*0x%s' % m.group(1)
        m = re.match(r'_([A-Za-z]\w*)$', ann)
        if m:
            return '&%s' % m.group(1)
        m = re.match(r'(.*) 0x([0-9a-f]+)$', ann)
        if m:
            return '%s@0x%s' % (m.group(1), m.group(2))
        return None

    def ev(self, op, ann=None, load=False):
        op = op.strip()
        if op.startswith('$'):
            v = int(op[1:], 16) if op[1:].startswith(('0x', '-0x')) else int(op[1:])
            if v < 0:
                return str(v)
            if v < 0x10000:
                return str(v) if v < 10 else hex(v)
            f = fbits(v)
            return '%s' % hex(v) + (' (f=%g)' % f if f is not None else '')
        if op.startswith('%'):
            return self.reg(op)
        m = re.match(r'^(-?0x[0-9a-f]+|-?\d+)?\((%\w+)(?:,(%\w+),(\d))?\)$', op)
        if m:
            off = int(m.group(1), 16) if m.group(1) else 0
            base = m.group(2)
            if m.group(3):
                return '%s[%s*%s%+d]' % (self.reg(base), self.reg(m.group(3)), m.group(4), off)
            if base == '%ebp':
                if off == 8:
                    return 'self'
                if off == 12:
                    return '_cmd'
                if off > 12:
                    return 'p%d' % ((off - 12) // 4)
                if off in self.locals:
                    v = self.locals[off]
                    return v[7:] + '.w0' if isinstance(v, str) and v.startswith('struct:') else v
                return self.local_struct(off)
            if base == '%esp':
                return self.slots.get(off, ('<esp%+d>' % off, 4))[0]
            if base == '%esi' and ann is not None:
                e = self.ann_expr(ann)
                if e:
                    return e
            b = self.reg(base)
            if b == 'self':
                return self.ivars.get(off, 'self->+0x%x' % off)
            if b.startswith('&'):
                return b[1:] + ('' if off == 0 else '[+%d]' % off)
            if b.startswith('*') is False and b.startswith('0x') is False:
                return '*(%s%+d)' % (b, off) if off else '*(%s)' % b
            return '*(%s%+d)' % (b, off) if off else '*(%s)' % b
        m = re.match(r'^(0x[0-9a-f]+)$', op)
        if m:
            return op
        return op

    def local_struct(self, off):
        for base in sorted(self.locals, reverse=True):
            if base <= off < base + 64 and isinstance(self.locals[base], str) and self.locals[base].startswith('struct:'):
                return '%s.w%d' % (self.locals[base][7:], (off - base) // 4)
        return 'local_%x' % (-off) if off < 0 else 'param+%x' % off

    # ---- statements -----------------------------------------------------------
    def emit(self, addr, text):
        self.out.append((addr, text))

    def store(self, dst, val, ann=None):
        dst = dst.strip()
        m = re.match(r'^(-?0x[0-9a-f]+|-?\d+)?\((%\w+)\)$', dst)
        if m:
            off = int(m.group(1), 16) if m.group(1) else 0
            if m.group(2) == '%esp':
                self.slots[off] = (val, 4)
                return
            if m.group(2) == '%ebp':
                self.locals[off] = val
                return
            b = self.reg(m.group(2))
            if b == 'self':
                return ('ivar', self.ivars.get(off, 'self->+0x%x' % off), val)
            return ('mem', '*(%s%+d)' % (b, off) if off else '*(%s)' % b, val)
        return None

    def run(self, lines):
        targets = set()
        for l in lines:
            m = re.search(r'\tj\w+\t0x([0-9a-f]+)', l)
            if m:
                targets.add(int(m.group(1), 16))
        regs = self.regs
        for l in lines:
            m = re.match(r'^([0-9a-f]+)\t(\w+)\t?(.*)$', l)
            if not m:
                continue
            addr = int(m.group(1), 16)
            mn = m.group(2)
            rest = m.group(3)
            ann = None
            if '##' in rest:
                rest, ann = rest.split('##', 1)
                rest = rest.strip()
                ann = ann.strip()
            elif ';' in rest:
                rest, ann = rest.split(';', 1)
                rest = rest.strip()
                ann = ann.strip()
            ops = split_ops(rest)
            if addr in targets:
                self.emit(addr, 'L%x:' % addr)
                for r in ('eax', 'ecx', 'edx', 'xmm0', 'xmm1', 'xmm2', 'xmm3', 'xmm4', 'xmm5', 'xmm6', 'xmm7'):
                    regs[r] = '<%s@L%x>' % (r, addr)
            a = lambda i: ops[i] if i < len(ops) else ''
            if mn in ('pushl', 'popl', 'retl', 'leave', 'nop'):
                if mn == 'retl':
                    self.emit(addr, 'return %s' % regs.get('eax', ''))
                continue
            if mn == 'movl' or mn == 'movzbl' or mn == 'movsbl' or mn == 'movzwl' or mn == 'movswl' or mn == 'movb' or mn == 'movw':
                src, dst = a(0), a(1)
                val = self.ev(src, ann)
                if dst.startswith('%'):
                    regs[dst.lstrip('%')] = val
                else:
                    st = self.store(dst, val)
                    if st:
                        self.emit(addr, '%s = %s' % (st[1], st[2]))
                continue
            if mn == 'leal':
                src, dst = a(0), a(1)
                e = self.ann_expr(ann) if '(%esi)' in src else None
                if e is None:
                    mm = re.match(r'^(-?0x[0-9a-f]+)?\((%\w+)\)$', src)
                    if mm:
                        off = int(mm.group(1), 16) if mm.group(1) else 0
                        if mm.group(2) == '%ebp':
                            e = '&local%+d' % off
                            if off in self.locals:
                                pass
                        else:
                            e = '(%s%+d)' % (self.reg(mm.group(2)), off)
                regs[dst.lstrip('%')] = e or 'lea(%s)' % src
                continue
            if mn in ('movss', 'movsd', 'movaps', 'movd', 'movq', 'movdqa', 'movups'):
                src, dst = a(0), a(1)
                val = self.ev(src, ann)
                if dst.startswith('%'):
                    regs[dst.lstrip('%')] = val
                else:
                    wide = 8 if mn in ('movsd', 'movq') else 16 if mn in ('movaps', 'movups', 'movdqa') else 4
                    mm = re.match(r'^(-?0x[0-9a-f]+|-?\d+)?\((%\w+)\)$', dst)
                    if mm:
                        off = int(mm.group(1), 16) if mm.group(1) else 0
                        if mm.group(2) == '%esp':
                            self.slots[off] = (val, wide)
                        elif mm.group(2) == '%ebp':
                            self.locals[off] = val
                        else:
                            st = self.store(dst, val)
                            if st:
                                self.emit(addr, '%s = %s' % (st[1], st[2]))
                continue
            if mn in ('addss', 'subss', 'mulss', 'divss', 'addsd', 'subsd', 'mulsd', 'divsd', 'addl', 'subl', 'imull', 'andl', 'orl', 'xorl', 'shll', 'sarl', 'shrl', 'addb', 'subb', 'andb', 'orb', 'xorps', 'andps', 'orps', 'xorpd', 'andpd', 'sqrtss', 'sqrtsd', 'minss', 'maxss', 'minsd', 'maxsd'):
                src, dst = a(0), a(1)
                if mn in ('subl', 'addl') and dst == '%esp':
                    continue
                opmap = {'add': '+', 'sub': '-', 'mul': '*', 'div': '/', 'and': '&', 'or': '|', 'xor': '^', 'imul': '*', 'shl': '<<', 'sar': '>>', 'shr': '>>>', 'min': 'min', 'max': 'max', 'sqrt': 'sqrt'}
                key = re.match(r'(add|sub|mul|div|and|or|xor|imul|shl|sar|shr|min|max|sqrt)', mn).group(1)
                if mn.startswith('xor') and src == dst:
                    val = '0'
                else:
                    s = self.ev(src, ann)
                    d = self.ev(dst)
                    val = '(%s %s %s)' % (d, opmap[key], s) if key not in ('min', 'max', 'sqrt') else '%s(%s, %s)' % (key, d, s)
                if dst.startswith('%'):
                    regs[dst.lstrip('%')] = val
                else:
                    st = self.store(dst, val)
                    if st:
                        self.emit(addr, '%s = %s' % (st[1], st[2]))
                    else:
                        mm = re.match(r'^(-?0x[0-9a-f]+)\(%ebp\)$', dst)
                        if mm:
                            self.locals[int(mm.group(1), 16)] = val
                continue
            if mn in ('incl', 'decl', 'negl', 'notl'):
                d = a(0)
                if d.startswith('%'):
                    cur = self.reg(d)
                    regs[d.lstrip('%')] = {'incl': '(%s + 1)', 'decl': '(%s - 1)', 'negl': '(-%s)', 'notl': '(~%s)'}[mn] % cur
                continue
            if mn in ('cvtsi2ss', 'cvtsi2sd', 'cvtss2sd', 'cvtsd2ss', 'cvttss2si', 'cvttsd2si', 'cvtdq2ps', 'cvtps2pd', 'cvtpd2ps', 'unpcklps', 'cvtss2si'):
                src, dst = a(0), a(1)
                t = {'cvtsi2ss': 'float', 'cvtsi2sd': 'double', 'cvtss2sd': 'double', 'cvtsd2ss': 'float', 'cvttss2si': 'int', 'cvttsd2si': 'int', 'cvtss2si': 'int'}.get(mn, mn)
                regs[dst.lstrip('%')] = '(%s)%s' % (t, self.ev(src, ann))
                continue
            if mn in ('cmpl', 'cmpb', 'cmpw', 'testl', 'testb', 'testw', 'ucomiss', 'comiss', 'ucomisd', 'comisd'):
                s, d = a(0), a(1)
                if mn.startswith('test'):
                    sv, dv = self.ev(s, ann), self.ev(d, ann)
                    self.lastcmp = (dv, '0') if s == d else ('(%s & %s)' % (dv, sv), '0')
                else:
                    self.lastcmp = (self.ev(d, ann), self.ev(s, ann))
                continue
            if mn.startswith('set') and len(mn) <= 6:
                cc = mn[3:]
                if self.lastcmp:
                    regs['eax' if a(0).lstrip('%') in ('al', 'ax') else a(0).lstrip('%')[:3].replace('b', 'e', 0)] = '(%s)' % self.cond(cc)
                    r = a(0).lstrip('%')
                    regs[{'al': 'eax', 'bl': 'ebx', 'cl': 'ecx', 'dl': 'edx', 'bh': 'ebx', 'ch': 'ecx', 'dh': 'edx'}.get(r, r)] = '(%s)' % self.cond(cc)
                continue
            if mn == 'cmov' or mn.startswith('cmov'):
                cc = mn[4:]
                if self.lastcmp:
                    regs[a(1).lstrip('%')] = '(%s ? %s : %s)' % (self.cond(cc), self.ev(a(0)), self.reg(a(1)))
                continue
            if mn == 'jmp':
                mm = re.match(r'0x([0-9a-f]+)$', a(0))
                if mm:
                    self.emit(addr, 'goto L%s' % mm.group(1))
                else:
                    self.emit(addr, 'switch/indirect jump %s  (see claude-tmp/hs/jtab.py)' % a(0))
                continue
            if mn.startswith('j') and mn != 'jmp':
                mm = re.match(r'0x([0-9a-f]+)$', a(0))
                if mm:
                    self.emit(addr, 'if (%s) goto L%s' % (self.cond(mn[1:]), mm.group(1)))
                continue
            if mn in ('fstpl', 'fstps', 'fstpt', 'fistpl', 'fistps'):
                d = a(0)
                val = self.lastcall or (self.fp.pop() if self.fp else 'fpu')
                if d.startswith('%'):
                    regs[d.lstrip('%')] = val
                else:
                    mm = re.match(r'^(-?0x[0-9a-f]+)\(%ebp\)$', d)
                    if mm:
                        self.locals[int(mm.group(1), 16)] = val
                    else:
                        mm = re.match(r'^(-?0x[0-9a-f]+|-?\d+)?\(%esp\)$', d)
                        if mm:
                            self.slots[int(mm.group(1), 16) if mm.group(1) else 0] = (val, 8)
                self.lastcall = None
                continue
            if mn in ('flds', 'fldl', 'fldt', 'fildl', 'filds'):
                self.fp.append(self.ev(a(0), ann))
                continue
            if mn.startswith('f'):
                if self.fp and mn in ('fadds', 'faddl', 'fsubs', 'fsubl', 'fmuls', 'fmull', 'fdivs', 'fdivl'):
                    op = {'fadd': '+', 'fsub': '-', 'fmul': '*', 'fdiv': '/'}[mn[:4]]
                    self.fp[-1] = '(%s %s %s)' % (self.fp[-1], op, self.ev(a(0), ann))
                continue
            if mn == 'calll':
                self.call(addr, a(0), ann)
                continue
            if mn in ('cltd', 'cdq', 'idivl', 'divl', 'mull', 'cwtl', 'sahf', 'fnstsw', 'xchgl', 'bswap', 'rep', 'stos', 'movsl'):
                if mn in ('idivl', 'divl'):
                    regs['eax'] = '(%s / %s)' % (regs.get('eax', 'eax'), self.ev(a(0)))
                    regs['edx'] = '(%s %% %s)' % (regs.get('eax', 'eax'), self.ev(a(0)))
                continue
            if mn.startswith('pshuf') or mn.startswith('punpck') or mn in ('unpcklps', 'shufps', 'movhlps', 'movlhps', 'pxor', 'por', 'pand', 'andnps'):
                continue
            self.emit(addr, '# %s %s' % (mn, ', '.join(ops)))

    def cond(self, cc):
        if not self.lastcmp:
            return cc
        d, s = self.lastcmp
        t = {'e': '==', 'z': '==', 'ne': '!=', 'nz': '!=', 'l': '<', 'g': '>', 'le': '<=', 'ge': '>=', 'b': '<u', 'a': '>u', 'be': '<=u', 'ae': '>=u',
             'nae': '<u', 'nb': '>=u', 'na': '<=u', 'nbe': '>u', 'nge': '<', 'nl': '>=', 'ng': '<=', 'nle': '>', 's': '< 0', 'ns': '>= 0', 'p': 'unordered', 'np': 'ordered'}
        if cc in ('s', 'ns'):
            return '%s %s' % (d, t[cc])
        return '%s %s %s' % (d, t.get(cc, cc), s)

    def call(self, addr, target, ann):
        name = None
        if ann:
            m = re.search(r'Objc message: (\w+)', ann)
            if m:
                name = m.group(1)
            m = re.search(r'symbol stub for: (\S+)', ann)
            if m:
                name = m.group(1)
        if name is None:
            name = ann or target
        self.ncall += 1
        n = self.ncall
        slots = self.slots
        offs = sorted(slots)

        def arg(o):
            return slots.get(o, ('<?>', 4))[0]
        res = 'r%d' % n
        text = None
        if name in ('_objc_msgSend', '_objc_msgSend_stret', '_objc_msgSend_fpret', '_objc_msgSendSuper', '_objc_msgSendSuper_stret', '_objc_msgSend_fixup'):
            base = 4 if name.endswith('stret') else 0
            recv = arg(base)
            sel = arg(base + 4)
            if name.startswith('_objc_msgSendSuper'):
                recv = 'super(%s)' % recv
            selname = sel[5:-1] if sel.startswith('@sel(') else None
            argoffs = [o for o in offs if o >= base + 8]
            vals = []
            o = base + 8
            while o in slots:
                vals.append(slots[o][0])
                o += slots[o][1]
            if selname is not None and ':' in selname:
                parts = selname.split(':')[:-1]
                ncol = len(parts)
                if len(vals) == ncol:
                    s = ' '.join('%s:%s' % (p, v) for p, v in zip(parts, vals))
                else:
                    s = ' '.join('%s:' % p for p in parts) + '  ARGS[%d words for %d colons]: %s' % (len(vals), ncol, ', '.join(vals))
            elif selname is not None:
                s = selname + (('  EXTRA ARGS: %s' % ', '.join(vals)) if vals else '')
            else:
                s = '%s  ARGS: %s' % (sel, ', '.join(vals))
            text = '[%s %s]' % (recv, s)
            if name.endswith('stret'):
                dst = arg(0)
                mm = re.match(r'&local([+-]\d+)$', dst)
                if mm:
                    off = int(mm.group(1))
                    self.locals[off] = 'struct:%s' % res
                text = '%s' % text
                res = res
            self.lastcall = None
            if name.endswith('fpret'):
                self.lastcall = res
        else:
            vals = []
            o = 0
            while o in slots:
                vals.append(slots[o][0])
                o += slots[o][1]
            text = '%s(%s)' % (name.lstrip('_'), ', '.join(vals))
            self.lastcall = res
        self.emit(addr, '%s = %s' % (res, text))
        for k, (v, w) in list(slots.items()):
            mm = re.match(r'^&local([+-]\d+)$', v)
            if mm and not (name.endswith('stret') and k == 0):
                o = int(mm.group(1))
                self.locals[o] = 'out%d(local%+d)' % (n, o)
        self.regs['eax'] = res
        self.regs['edx'] = res + '.hi'
        self.regs['ecx'] = '<clobbered>'
        self.slots = {}


def load_ivars(cls):
    iv = {}
    if not cls:
        return iv
    for d in ('HyperStudio', 'HyperPlayerBase', 'HyperEditorBase', 'SMKApplicationKit', 'SMKBitmapTools', 'SMKControls', 'SMKPublish', 'HSQTKit'):
        p = os.path.join(ROOT, 'src', d, cls + '.m')
        if os.path.exists(p):
            s = open(p, errors='replace').read()
            m = re.search(r'/\* i386 ivar offsets: (.*?) \*/', s)
            if m:
                for kv in m.group(1).split(', '):
                    k, v = kv.split('=')
                    iv[int(v, 16)] = k
    return iv


def main():
    args = sys.argv[1:]
    cls = None
    if '-c' in args:
        i = args.index('-c')
        cls = args[i + 1]
        del args[i:i + 2]
    binary, func = args[0], args[1]
    r = subprocess.run([sys.executable, os.path.join(ROOT, 'tools', 'dis.py'), '-a', binary, func], capture_output=True, text=True, cwd=ROOT)
    lines = r.stdout.splitlines()
    t = Tracer(binary, load_ivars(cls))
    t.run(lines)
    # resolve protocols and data pointers
    names = {}
    if t.protos:
        r = subprocess.run([sys.executable, os.path.join(ROOT, 'tools', 'protoaddr.py'), 'analysis/%s-i386' % binary] + list(t.protos), capture_output=True, text=True, cwd=ROOT)
        for l in r.stdout.splitlines():
            p = l.split()
            if len(p) == 2:
                names[p[0]] = p[1]
    ptrs = {}
    if t.dataptrs:
        r = subprocess.run([sys.executable, '/Volumes/SSD/larsen/claude-tmp/hs/pp.py', binary] + list(t.dataptrs), capture_output=True, text=True, cwd=ROOT)
        vals = {}
        for l in r.stdout.splitlines():
            p = l.split()
            if len(p) == 3:
                vals[p[0]] = p[2].replace('0x', '').rjust(8, '0')
        dm = {}
        for d in ('HyperStudio', 'HyperPlayerBase', 'HyperEditorBase'):
            for f in ('%sData.m' % d,):
                pth = os.path.join(ROOT, 'src', d, f)
                if os.path.exists(pth):
                    for l in open(pth, errors='replace'):
                        m = re.search(r'NSString \* const (\w+) = .*// ([0-9a-f]{8})', l)
                        if m:
                            dm[m.group(2)] = m.group(1)
                        m = re.search(r'(\w+) = .*// ([0-9a-f]{8})$', l.strip())
                        if m:
                            dm.setdefault(m.group(2), m.group(1))
        for k, v in vals.items():
            ptrs[k] = dm.get(v, 'data@' + v)
    for addr, text in t.out:
        for k, v in names.items():
            text = text.replace('@protocol(%s)' % k, '@protocol(%s)' % v)
        for k, v in ptrs.items():
            text = text.replace('*0x%s' % k, v)
        print('%x  %s' % (addr, text))


if __name__ == '__main__':
    main()
