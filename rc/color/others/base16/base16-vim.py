import re
import requests

# url = 'https://raw.githubusercontent.com/chriskempson/base16-vim/master/colors/base16-default-dark.vim'
# r = requests.get(url)
# text=r.text
text=open('others/base16/xx','r').read()
def _parse_cterm_mapping(text):
    ret = []
    for line in text.splitlines():
        m = re.search(r'''^\s*let\s*s:cterm(\w+)\s*=\s*["'](\d+)["']''', line)
        if m:
            ret.append(m.groups())
    # here ret is sequence of (k, v) pairs, but k is not unique, due to if branch
    # now choose policy: last matters
    return dict(ret)
_d_cterm=_parse_cterm_mapping(text)
print({k:int(v) for k,v in _d_cterm.items()})
def _hi(lst):
# fun <sid>hi(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
    assert(len(lst) == 7)
    ret = 'hi ' + lst[0]
    ctermfg, ctermbg, attr = (i.strip(r""""'""") for i in lst[3:6])
    if ctermfg:
        x = re.search('^s:cterm([0-9a-fA-F]{2})$', ctermfg)[1]
        ret += ' ctermfg=' + _d_cterm[x]
    if ctermbg:
        x = re.search('^s:cterm([0-9a-fA-F]{2})$', ctermbg)[1]
        ret += ' ctermbg=' + _d_cterm[x]
    if attr:
        ret += ' cterm=' + attr
    return ret
def parse_base16_highlight(text):
    ret = []
    for line in text.splitlines():
        m = re.search(r'^\s*call <sid>hi\((.*)\)', line)
        if m:
            x= re.search(r'''(['"])([^'"]*)\1''' + r'''\s*,\s*([^,]+?)''' * 6 +
                    r'\s*$',m[1])
            # print(x.groups(), len(x.groups()))
            x = x.groups()[1:]
            ret.append(_hi(x))
    return ret
x=parse_base16_highlight(text)
def write_to(x, path):
    with open(path,'w') as f:
        f.write('''hi clear
syntax reset
let g:colors_name = "base16"\n\n''')
        f.writelines('\n'.join(x))
write_to(x, 'yy')
# j=[i for i in x if 'TabLine' in i][0]
# # a= re.search(r'''(['"])([^'"]*)\1''' + r'''\s*,\s*([^,]+?)''' * 6,j)
# # a= re.search(r'''(['"])([^'"]*)\1''' + r'''\s*,\s*([^,]+?)''' * 6 + '$',j)
# print(r'''(['"])([^'"]*)\1''' + r'''\s*,\s*([^,]+?)''' * 6 + r'\s*$')
# # a= re.search(r'''(['"])([^'"]*)\1''' + r'''\s*,\s*([^,]+?)''' * 6 + r'\s*$',j)
# a= re.search(r'''(['"])([^'"]*)\1''' + r'''\s*,\s*([^,]+?)''' * 6 + r'\s*$',j)
# print(a.groups(), len(a.groups()))
