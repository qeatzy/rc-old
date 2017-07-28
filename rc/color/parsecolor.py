# nn <buffer> <space>r :<C-u>!python3 %<CR>
import os
import re
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

_TMUX = os.environ.get('TMUX')
ESC_BEGIN = '\033Ptmux;\033\033]' if _TMUX else '\033]'
ESC_END = '\a\033\\' if _TMUX else '\a'
def spec(name, value):
    def _code2spec(code):
        assert(-3 <= name <= 255)
        return '{}'.format(code+13) if code < 0 else '4;{};'.format(code)
    if isinstance(value,(list,tuple)):
        assert(len(value) == 3)
        value = '{},{},{}'.format(*value)
    else:
        assert(isinstance(value,str))
    return '{}{}{}{}'.format(ESC_BEGIN,
            _code2spec(name),value,
            ESC_END)

def _cindex(name):
    if isinstance(name,str):
        m = re.match(r'x?([+-]\d+)$', name)
        if m:
            name = int(m.group(1))
    if isinstance(name,int):
        assert(-3 <= name <= 255)
        return name
    else:
        assert(isinstance(name,str))
        inc = 0
        name = name.lower()
        if name.startswith('bright_'):
            name = 'bold' + name[7:]
        return __codes[name]

# https://github.com/jeffkreeftmeijer/appsignal.terminal/issues/2
# .+,.+16s/".*"/"000000"/
colors = """[
-3: 000000,
backgroundcolour: 000000,
cursorcolour: 000000,
  black: "000000",
  red: "000000",
  green: "000000",
  yellow: "000000",
  blue: "000000",
  magenta: "000000",
  cyan: "000000",
  white: "000000",
  bright_black: "000000",
  bright_red: "000000",
  bright_green: "000000",
  bright_yellow: "000000",
  bright_blue: "000000",
  bright_magenta: "000000",
  bright_cyan: "000000",
  bright_white: "000000"
]"""

def parse_colors(colors):
    def _parse(co):
        name, val = [i.strip(' "') for i in co.split(':')]
        val = [int(val[i:i+2],base=16) for i in (0,2,4)]
        return _cindex(name), val
    return [_parse(co) for co in colors]

res = parse_colors([i.strip(' \n[]') for i in colors.split(',')])
print(res)
print(len(res))

# print(''.join(spec(name,value) for name,value in res))
print(''.join(spec(name,'0,0,0') for name in range(-3,256)))

# impo
