import sys,os,re
# usage: sh.py Binary 'Class sel' ...   (kind from metadata unknown: tries - then +)
b=sys.argv[1]; base='/Volumes/SSD/larsen/HyperStudioAuthor-Universal2/analysis/decomp/%s-i386'%b
idx=[l.rstrip('\n').split('\t') for l in open(base+'/index.tsv')]
def san(x): return re.sub(r'[^A-Za-z0-9_\[\]+\- ]','_',x)
for a in sys.argv[2:]:
    kind='-'
    if a[0] in '+-': kind,a=a[0],a[1:].strip()
    c,sel=a.split(' ',1)
    want='%s[%s_%s]'%(kind,c,sel.replace(':','_'))
    hit=[r for r in idx if r[3]==want+'.c' or r[2]==want]
    if not hit: print('=== %s: NOT FOUND'%want); continue
    print('=== '+want)
    for l in open(base+'/'+hit[0][3]):
        l=l.rstrip()
        if l.strip() and not re.match(r'^\s+[A-Za-z_][\w \*]* [\*\w]+;$',l): print(l)
