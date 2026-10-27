#!/usr/bin/env python3
"""Replaces translated methods in a skeleton file: for each method in the
input, the stub with the same declaration line and the decompilation comment
just above it are replaced by the given method (with its own comment, if any).

The input holds whole methods (an "@implementation Class" or
"@implementation Class (Category)" line limits the following ones to that
block of the file), each starting with its declaration line
("- (...)name..." or "+ (...)"), optionally preceded by // comment lines, and
ending with a "}" line at column 0.

usage: put.py <file.m> <methods.m>      (or - for stdin)
"""
import re
import sys


def methods(text):
    out, cur, lead, scope = [], None, [], None
    for line in text.splitlines(keepends=True):
        if cur is None:
            if line.startswith('@implementation '):
                scope = line.strip()
            elif line.startswith(('- (', '+ (')):
                cur = [line]
            elif line.startswith('//') or (lead and line.strip() == ''):
                lead.append(line)
            elif line.strip():
                sys.exit('unexpected line outside a method: ' + line)
            continue
        cur.append(line)
        if line.rstrip() == '}':
            out.append((scope, cur[0].rstrip(), ''.join(lead).lstrip('\n'), ''.join(cur)))
            cur, lead = None, []
    if cur is not None:
        sys.exit('unterminated method: ' + cur[0])
    return out


def key(decl):
    return re.sub(r'\s+', ' ', decl.split('{')[0]).strip()


def main():
    path, src = sys.argv[1:3]
    text = open(path).read()
    new = open(src).read() if src != '-' else sys.stdin.read()
    for scope, decl, lead, body in methods(new):
        stub = re.compile('^' + re.escape(decl) + r'\n\{\n    HS_UNTRANSLATED\(\);\n(?:    .*\n|\n)*?\}\n', re.M)
        lo, hi = 0, len(text)
        if scope:
            lo = text.find(scope + '\n')
            if lo < 0:
                sys.exit('no %s in %s' % (scope, path))
            hi = text.find('\n@end', lo)
        hits = [h for h in stub.finditer(text) if lo <= h.start() < hi]
        if len(hits) != 1:
            sys.exit('%d stubs for %s in %s' % (len(hits), decl, path))
        a, b = hits[0].span()
        # the decompilation comment right above it
        if text[:a].endswith('*/\n'):
            c = text.rfind('/* --- i386 decompilation (Ghidra) ---\n', 0, a)
            if c >= 0 and not re.search(r'^(?:[-+] \(|@implementation|@end)', text[c:a], re.M):
                a = c
        text = text[:a] + lead + body + text[b:]
    open(path, 'w').write(text)


if __name__ == '__main__':
    main()
