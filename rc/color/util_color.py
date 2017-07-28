import re
try: import ipdb as pdb
except: import pdb
st=pdb.set_trace
from collections import Counter
from data import CaseInsensitiveDict
from data import read_local_file
import lxml
from lxml import html

def _v_rgb(rgb):
    r,g,b = rgb
    return all(i>=0 and i<=255 for i in (r,g,b))
def rgb2hex(rgb):
    r,g,b = rgb
    return '#{:02x}{:02x}{:02x}'.format(r,g,b)


def _get_all_colors(s):
    m = re.findall('#[0-9a-fA-F]{6}',s)
    return m

def _get_cterm_fg_bg(s):
    # ctermfg=243 ctermbg=235
    ret = []
    for i,line in enumerate(s.splitlines()):
        x = re.findall('ctermfg=(\S+).+(?:ctermbg=(\S+))',line)
        # if len(x) == 0:
        if len(x) == 0: continue
        if len(x) != 0 and len(x[0]) < 2:
            st()
        else:
            ret.append(x[0])
        # if m
    return ret

files = [
'/home/zyq3e/.colors/falcon/autoload/airline/themes/falcon.vim',
'/home/zyq3e/.colors/falcon/autoload/lightline/colorscheme/falcon.vim',
'/home/zyq3e/.colors/falcon/colors/falcon.vim',
'/home/zyq3e/.colors/falcon/plugin/falcon.vim',
]
def f():
    ret = [_get_all_colors(read_local_file(fn)) for fn in files]
    return ret
x=f()
print([len(i) for i in x])
x = [set(i) for i in x]
print([len(i) for i in x])
a,b,c,d=x
ca = set.union(*x)
print(len(ca))

x=_get_cterm_fg_bg(read_local_file(files[2]))
a,b=zip(*x)
print(len(a),len(b))
a,b=set(a),set(b)
print(len(a),len(b))
x=a.union(b)
x.remove('NONE')
print(len(x))

iterm2 = '/home/zyq3e/.colors/falcon/iterm2/falcon.itermcolors'
def _paser_iterm2(root):
    x = root.xpath('//plist/dict')
    assert(len(x) == 1)
    x = x[0]
    assert(len(x) % 2 == 0)
    ret = {}
    for i in range(len(x) // 2):
        c,d = x[i*2], x[i*2+1]
        assert(c.tag == 'key' and len(d) % 2 == 0)
        item = {}
        for i in range(len(d)//2):
            k,v = d[i*2], d[i*2+1]  
            assert(k.tag == 'key')
            v = float(v.text) if v.tag == 'real' else v.text
            item[k.text] = v
        ret[c.text] = item
    # st()
    # for
    return ret

def _item2_to_rgb(d):
    # {'Alpha Component': 1.0,
    #  'Blue Component': 0.01568627543747425,
    #  'Color Space': 'sRGB',
    #  'Green Component': 0.0,
    #  'Red Component': 0.0}
    ret = {}
    for k,v in d.items():
        m = re.search('Ansi (\d+) Color',k)
        if m:
            k = int(m.group(1))
        rgb = [v[i]*255 for i in ('Blue Component', 'Green Component', 'Red Component')]
        def _v(x):
            _,r=divmod(x,1)
            return r if r < 0.5 else 1 - r
        assert(all(_v(i) < 0.1 for i in rgb))
        rgb = tuple(round(i) for i in rgb)
        _v_rgb(rgb)
        ret[k] = rgb
    return ret

a = lxml.etree.parse(iterm2).getroot()
x = _paser_iterm2(a)
print(x.keys())
print(len(x.keys()))
print(sum(i.startswith('Ansi') for i in x))
print('Alpha Component', Counter(i['Alpha Component'] for i in x.values()))
k=list(x.keys())
t=_item2_to_rgb(x)
ci = set(rgb2hex(i) for i in t.values())

def _parse_mintty(s):
    ret = {}
    for line in s.splitlines():
        m = re.search('(\w+)\s*=\s*(\S+)',line)
        if m:
            k,v = m.group(1), m.group(2)
            m2 = re.match('(\d+),(\d+),(\d+)$', v)
            if m2:
                rgb = tuple(int(i) for i in m2.groups())
                assert(_v_rgb(rgb))
                ret[k.lower()] = rgb
            elif v.lower() in ret:
                ret[k.lower()] = ret[v.lower()]
            else:
                raise ValueError(line)
    return ret

def fetch_theme(name):
    if name == 'falcon-mintty':
        return _parse_mintty(read_local_file('/home/zyq3e/.colors/falcon/mintty/.minttyrc'))

xm=fetch_theme('falcon-mintty')
cm=set(rgb2hex(i) for i in xm.values())

def parse_color(color):
    """ color: string, specify rgb value. """
    m = re.match('#?#?([0-9a-fA-F]{6})$', color)
    if m:
        return tuple(int(m.group(1)[i:i+2],base=16) for i in (0,2,4))
def parse_spec(specs):
    """ specs: iterable of (color_name, color_sec) pair """
    # theme_name = None
    ret = []
    _d = {}
    for name, value in specs:
        if name == 'PROFILE_NAME':
            theme_name = value.replace(' ','-')
            continue
        if name in _unsupported:
            continue
        m = re.match('COLOR_(\d+)', name)
        if m:
            code = int(m.group(1))
        else:
            # try:
            code = _mapper[name]
        if value.startswith('$'):
            val = _d[value[1:]]
        else:
            val = parse_color(value)
        _d[name] = val
        ret.append((code, val))
    return theme_name, ret
