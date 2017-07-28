import os, sys
import re
from functools import wraps
# import ipdb; st=ipdb.set_trace
import requests
from collections import Mapping
from requests.structures import CaseInsensitiveDict

def _add_parent_to_path(fn, level=1, abs=True):
    """ level=1 to add current directory, level=0 to add fn itself, """
    import os, sys
    if abs:
        fn = os.path.abspath(fn)
    while level > 0:
        fn = os.path.dirname(fn)
        level -= 1
    sys.path.append(fn)
# _add_parent_to_path(__file__,3)

__codes = dict(
    foregroundcolour=-3,
    backgroundcolour=-2,
    cursorcolour=-1,
    black=0,
    red=1,
    green=2,
    yellow=3,
    blue=4,
    magenta=5,
    cyan=6,
    white=7,
    boldblack=8,
    boldred=9,
    boldgreen=10,
    boldyellow=11,
    boldblue=12,
    boldmagenta=13,
    boldcyan=14,
    boldwhite=15,
)

def read_local_file(fn):
    with open(fn, 'r') as f:
        return f.read()

_TMUX = os.environ.get('TMUX')
ESC_BEGIN = '\033Ptmux;\033\033]' if _TMUX else '\033]'
ESC_END = '\a\033\\' if _TMUX else '\a'
COLOR_SPEC = '{},{},{}' if sys.platform == 'cygwin' else '#{:02x}{:02x}{:02x}'
def set_theme(theme):
    """ theme: a sequence of name, value.  -3 <= name <= 255, value = (r,g,b), 0 <= r,g,b <= 255 """
    if isinstance(theme, Mapping):
        theme = theme.items()
    lst = []
    for name, value in theme:
        assert(-3 <= name <= 255 and len(value) == 3 and 0 <= value[0] <= 255
                and 0 <= value[1] <= 255 and 0 <= value[2] <= 255)
        lst.append(''.join('{}{}{}{}'.format(ESC_BEGIN,
                '4;{};'.format(name) if name >= 0 else '{};'.format(name+13),
                COLOR_SPEC.format(*value),
                ESC_END)))
    # print(lst)
    # print(''.join(lst),end='') # control sequence to terminal
    return ''.join(lst) # control sequence to terminal
# set_theme(f0(t0))
# set_theme(f1(t1))
# # set_theme(f2(t2))

def _v_rgb(rgb):
    r,g,b = rgb
    return all(i>=0 and i<=255 for i in (r,g,b))
def rgb2hex(rgb):
    r,g,b = rgb
    return '#{:02x}{:02x}{:02x}'.format(r,g,b)
def hex2rgb(s):
    m = re.search('^#*([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$', s)
    if m:
        rgb = tuple(int(i,base=16) for i in m.groups())
        assert(_v_rgb(rgb))
        return rgb

_table = {ord(':'):'+',ord('/'):'_'}
def _check_if_url_and_trans_to_valid_filename(url):
    assert(url.startswith('http'))
    return url.translate(_table)
def cache_to(dir=None):
    prefix=os.path.join(cache_to.prefix, dir or 'tmp')
    os.makedirs(prefix,exist_ok=True)
    def _intermediate(func):
        cache = {}
        # @wraps
        def inner(*args, **kwargs):
            # func: first argument is url, return string or None
            url = args[0]
            fn = _check_if_url_and_trans_to_valid_filename(url)
            try:
                with open(os.path.join(prefix, fn), 'r') as f:
                    ret = f.read()
            except FileNotFoundError:
                ret = func(*args, **kwargs)
                if ret is not None:
                    with open(os.path.join(prefix, fn), 'w') as f:
                        f.write(ret)
            return ret
        inner.cache = cache
        return inner
    return _intermediate
cache_to.prefix=os.path.expanduser('~/.colors')
# print(cache_to())
# print(cache_to('Gogh'))
# print(cache_to('base16'))

@cache_to()
def fetch_url(url):
    r = requests.get(url)
    if r:
        return r.text

def get(url_or_path):
    if url_or_path.startswith('http'):
        return fetch_url(url_or_path)

def parse_mintty_theme(text):
    ret = {}
    for line in text.splitlines():
        m = re.search(r'^\s*(\w+)\s*=\s*(\S+)',line)
        if m:
            key = __codes[m[1].lower()]
            # st()
            rgb = tuple(int(i) for i in m[2].split(','))
            _v_rgb(rgb)
            ret[key] = rgb
    return ret
