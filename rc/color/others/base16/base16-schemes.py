import re
import requests
# import ipdb; st=ipdb.set_trace
def _add_parent_to_path(fn, level=1, abs=True):
    """ add fn itself, use level=0 """
    import os, sys
    if abs:
        fn = os.path.abspath(fn)
    while level > 0:
        fn = os.path.dirname(fn)
        level -= 1
    sys.path.append(fn)
_add_parent_to_path(__file__,3)
from data import *
url = 'https://raw.githubusercontent.com/chriskempson/base16-schemes-source/master/list.yaml'
unclaimed = 'https://github.com/chriskempson/base16-unclaimed-schemes'
# r=requests.get(url)
# text=r.text
# x=text

# from _d_cterm in others/base16/base16-vim.py
# base00: backgroundcolour
# base05: foregroundcolour
# mintty:
# CursorColour: foregroundcolour
# gnome-terminal:
# cursor-foregroundcolour-color: backgroundcolour
# cursor-background-color: foregroundcolour
_d_cterm = {'00': 0,
 '03': 8,
 '05': 7,
 '07': 15,
 '08': 1,
 '0A': 3,
 '0B': 2,
 '0C': 6,
 '0D': 4,
 '0E': 5,
 '01': 10,
 '02': 11,
 '04': 12,
 '06': 13,
 '09': 9,
 '0F': 14}


url = 'https://raw.githubusercontent.com/ZoeFiri/base16-summercamp/master/summercamp.yaml'
r=requests.get(url)
text=r.text
x=text
def parse_base16_scheme(text):
    theme = {}
    for line in text.splitlines():
        m = re.search(r'''^\s*([^:]+)\s*:\s*["']([^"']+)["']''', line)
        if m:
            # st()
            k,v = m[1], m[2]
            if k == 'scheme':
                name = v
            elif k.startswith('base0'):
                theme[_d_cterm[k[4:]]] = hex2rgb(v)
    theme[-1]=theme[_d_cterm['05']]  # CursorColour
    theme[-2]=theme[_d_cterm['00']]  # backgroundcolour
    theme[-3]=theme[_d_cterm['05']]  # foregroundcolour
    return name, theme
x = parse_base16_scheme(text)
print(x)
print(set_theme(x[1].items()))
