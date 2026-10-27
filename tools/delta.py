import json,sys
fw=['HyperStudio','HyperEditorBase','HyperPlayerBase','SMKApplicationKit','SMKBitmapTools','SMKControls']
def load(p):
    d={}
    for e in json.load(open(p)):
        for c in e['classes']:
            d[c['name']]=c
    return d
tot={}
rep=[]
for f in fw:
    A=load('analysis/objc-%s.json'%f)
    B=load('baseline-analysis/objc-%s.json'%f)
    onlyA=sorted(set(A)-set(B)); onlyB=sorted(set(B)-set(A))
    mA=mB=0; chg=[]
    newm=[]; gone=[]; ivch=[]
    for n in set(A)&set(B):
        for kind in('imethods','cmethods'):
            sa={m['sel'] for m in A[n][kind]}; sb={m['sel'] for m in B[n][kind]}
            for s in sorted(sa-sb): newm.append((n,kind[0],s))
            for s in sorted(sb-sa): gone.append((n,kind[0],s))
        ia=[(i['name'],i['type']) for i in A[n]['ivars']]; ib=[(i['name'],i['type']) for i in B[n]['ivars']]
        if ia!=ib: ivch.append(n)
    ma=sum(len(c['imethods'])+len(c['cmethods']) for c in A.values()); mb=sum(len(c['imethods'])+len(c['cmethods']) for c in B.values())
    print('%-18s classes HSA %4d HS5 %4d  onlyHSA %3d onlyHS5 %3d | methods HSA %5d HS5 %5d | newSel %4d goneSel %4d ivarChanged %3d'%(f,len(A),len(B),len(onlyA),len(onlyB),ma,mb,len(newm),len(gone),len(ivch)))
    rep.append((f,onlyA,onlyB,newm,gone,ivch))
json.dump(rep,open('docs/delta.json','w'))
