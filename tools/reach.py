#!/usr/bin/env python3
"""Dead-code sweep for <Target>Functions.m: given a seed file of translated function
names, writes <seed>.closed with every untranslated entry reachable only from them
(not from other untranslated roots or from translated src/ files). Feed it to drop_fn.py.

usage: reach.py src/<T>/<T>Functions.m <seedfile>  (run from the project root)
"""
import re,sys,glob
path, seedfile = sys.argv[1], sys.argv[2]
s=open(path).read()
heads=list(re.finditer(r'^/\* (\S+) @ ([0-9a-f]+), (\d+) bytes', s, re.M))
bodies={}
for i,m in enumerate(heads):
    end=heads[i+1].start() if i+1<len(heads) else len(s)
    bodies[m.group(1)]=s[m.end():end]
refs={n:set(re.findall(r'\b(FUN_[0-9a-f]{8})\b',b))-{n} for n,b in bodies.items()}
ext=set()
for f in glob.glob('src/**/*.[mh]',recursive=True):
    if f.endswith('Functions.m'): continue
    ext|=set(re.findall(r'\b(FUN_[0-9a-f]{8})\b',open(f,errors='ignore').read()))
drop=set(l.strip() for l in open(seedfile) if l.strip())
def reach(start):
    seen=set(); st=list(start)
    while st:
        n=st.pop()
        if n in seen: continue
        seen.add(n); st.extend(refs.get(n,()))
    return seen
fromdrop=reach(drop)
roots=[n for n in bodies if n not in drop and not n.startswith('FUN_')]
# FUN_ that are referenced by nothing are roots too (callbacks via tables), unless reached from drop
allref=set().union(*refs.values())
roots+= [n for n in bodies if n.startswith('FUN_') and n not in allref and n not in fromdrop]
live=reach(roots)|ext
dead={n for n in fromdrop if n not in live and n in bodies}
print(len(dead), sum(int(m.group(3)) for m in heads if m.group(1) in dead))
open(seedfile+'.closed','w').write('\n'.join(sorted(dead))+'\n')
