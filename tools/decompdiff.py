# Diff two builds of a framework method by method: decompiles with addresses and
# variable names normalized. Usage: decompdiff.py <WG objc json> <HS objc json> <out>
# (each objc json: analysis/objc-<Binary>.json; decompile dirs are found next to them).
import json,sys,re,os,difflib
W,H,S=sys.argv[1:4]
def load(p):
    out={}
    for x in json.load(open(p)):
        for c in x['classes']+x['categories']:
            n=c['name'] if 'class' not in c else c['class']+'('+c['name']+')'
            for k in ('imethods','cmethods'):
                for m in c.get(k) or []:
                    out[('-' if k=='imethods' else '+')+'['+n+' '+m['sel']+']']=int(m['imp'],16)
    return out
DECL=re.compile(r'^(const )?(id|undefined\d*|int|uint|char|byte|float|double|SEL|bool|ushort|short|longlong|ulonglong|code|float10|cfstringStruct|NS\w+|CG\w+|_\w+|SMK\w+|objc_\w+|\w+_t)\s*\**\s*[A-Za-z_]\w*(\s*\[\d+\])?;$')
def text(d,a):
    p=os.path.join(d,'FUN_%08x.c'%a)
    if not os.path.exists(p): return None
    t='\n'.join(open(p).read().split('\n')[1:])
    t=re.sub(r'\w*Ram[0-9a-f]+','G',t)
    t=re.sub(r'PTR_(\w+?)_0[0-9a-f]{7}',r'PTR_\1',t)
    t=re.sub(r'\b(FUN|DAT|LAB|PTR|switchD|caseD|code_r0x|PTR_DAT)_[0-9a-f]+','X',t)
    t=re.sub(r'0x[0-9a-f]{5,8}','X',t)
    t=re.sub(r'\b(local|uStack|auStack|iStack|fStack|pvStack|in_stack|unaff|extraout|in)_[0-9a-zA-Z_]+','V',t)
    t=re.sub(r'\b(pvVar|iVar|uVar|fVar|dVar|pcVar|bVar|cVar|puVar|pfVar|ppvVar|piVar|lVar|sVar|ppcVar|pbVar|self_|pSVar|ppuVar|pdVar|psVar|pvRam)\d+\b','V',t)
    lines=[l.strip() for l in t.split('\n') if l.strip()]
    return [l for l in lines if not DECL.match(l)]
w=load(W+'/analysis/objc-smkcontrols.json'); h=load(H+'/analysis/objc-SMKControls.json')
wd=W+'/analysis/decomp/smkcontrols-i386'; hd=H+'/analysis/decomp/SMKControls-i386'
out=open(S+'/smk_diff.txt','w'); changed=[]
for k in sorted(h):
    ht=text(hd,h[k]); wt=text(wd,w[k]) if k in w else None
    if k not in w: changed.append((k,'NEW')); out.write('#### NEW '+k+'\n'+'\n'.join(ht or [])+'\n'); continue
    if ht is None or wt is None: changed.append((k,'nofile')); continue
    if ht!=wt:
        dl=list(difflib.unified_diff(wt,ht,lineterm='',n=1))
        changed.append((k,len(dl)))
        out.write('#### '+k+'\n'+'\n'.join(dl[2:])+'\n')
for c in changed: print(c)
print(len(changed))
