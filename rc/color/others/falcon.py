import re, sys, os
import ipdb; st=ipdb.set_trace
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from data import *
dir_root = '/home/zyq3e/.colors/falcon'
# estilo/palettes/falcon.yml

fn_vim = 'colors/falcon.vim'
# /home/zyq3e/.colors/falcon/colors/falcon.vim
def parse_vim():
    text = read_local_file(os.path.join(dir_root, fn_vim))
    ret = {}
    for line in sorted(text.splitlines(), key=lambda s: (1 if
        re.search('\slink\s', s) else 0)):
        d = {}
        if re.search('^\s*(?:hi|highlight) ', line):
            m = re.search('^\s*(?:hi|highlight)\s+link\s+(\S+)\s*(\S+)', line)
            if m:
                ret[m[1]] = ret[m[2]]
            else:
                m = re.search('ctermfg=(\S*)', line)
                d['ctermfg'] = m.group(1) if (m and m[1].upper() != 'NONE') else None
                m = re.search('guifg=(\S*)', line)
                d['guifg'] = m.group(1) if (m and m[1].upper() != 'NONE') else None
                name = re.search('^\s*(?:hi|highlight)\s+(\S+)', line)[1]
                ret[name] = d
    return ret
x0=parse_vim()
x=x0.values()
print(len(x))
x1=[d for d in x if all(i for i in d.values())]
print(len(x1))
x2=[d for d in x if any(i for i in d.values())]
print(len(x2))
co = [tuple(d.values()) for d in x1]
print(len(co))
co2 = sorted(set(co))
print(len(co2), len(dict(co)))
co3 = [(int(i),hex2rgb(j)) for i,j in co2]
x=set_theme(co3)
# vim: path+=/home/zyq3e/.colors/falcon
