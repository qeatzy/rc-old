#!python3
# nn <buffer> <space>r :<C-u>!./% set ma-l<CR>
# https://raw.githubusercontent.com/joakimkarlsson/mintty-colors/master/mtc.py
# https://github.com/joakimkarlsson/mintty-colors
# https://superuser.com/a/1081928/487198
import pdb; st=pdb.set_trace
import sys, os
import re

__doc__ = """Usage: mtc.original.py [OPTIONS] COMMAND [ARGS]...

Options:
  --help  Show this message and exit.

Commands:
  list  List available color themes
  set   Set a color theme
"""

BUILTIN_THEMES = '''
[onedark]
ForegroundColour=171,178,191
BackgroundColour=30,33,39
CursorColour=97,175,239
BoldBlack=92,99,112
Black=92,99,112
BoldRed=224,108,117
Red=224,108,117
BoldGreen=152,195,121
Green=152,195,121
BoldYellow=209,154,102
Yellow=209,154,102
BoldBlue=97,175,239
Blue=97,175,239
BoldMagenta=198,120,221
Magenta=198,120,221
BoldCyan=86,182,194
Cyan=86,182,194
BoldWhite=171,178,191
White=171,178,191

[material-dark]
BackgroundColour=35,35,34
ForegroundColour=229,229,229
CursorColour=229,229,229
Black=33,33,33
BoldBlack=66,66,66
Red=183,20,31
BoldRed=232,59,63
Green=69,123,36
BoldGreen=122,186,58
Yellow=246,152,30
BoldYellow=255,234,46
Blue=19,78,178
BoldBlue=84,164,243
Magenta=86,0,136
BoldMagenta=170,77,188
Cyan=14,113,124
BoldCyan=38,187,209
White=239,239,239
BoldWhite=217,217,217

[material-light]
BackgroundColour=234,234,234
ForegroundColour=46,46,45
CursorColour=46,46,45
Black=33,33,33
BoldBlack=66,66,66
Red=183,20,31
BoldRed=232,59,63
Green=69,123,36
BoldGreen=122,186,58
Yellow=252,123,8
BoldYellow=253,142,9
Blue=19,78,178
BoldBlue=84,164,243
Magenta=86,0,136
BoldMagenta=170,77,188
Cyan=14,113,124
BoldCyan=38,187,209
White=239,239,239
BoldWhite=217,217,217

[solarized-light]
BackgroundColour=253,246,227
ForegroundColour=88,110,117
CursorColour=88,110,117
Black=0,43,54
BoldBlack=101,123,131
Red=220,50,47
BoldRed=220,50,47
Green=133,153,0
BoldGreen=133,153,0
Yellow=181,137,0
BoldYellow=181,137,0
Blue=38,139,210
BoldBlue=38,139,210
Magenta=108,113,196
BoldMagenta=108,113,196
Cyan=42,161,152
BoldCyan=42,161,152
White=147,161,161
BoldWhite=253,246,227

[solarized-dark]
BackgroundColour=0,43,54
ForegroundColour=147,161,161
CursorColour=147,161,161
Black=0,43,54
BoldBlack=101,123,131
Red=220,50,47
BoldRed=220,50,47
Green=133,153,0
BoldGreen=133,153,0
Yellow=181,137,0
BoldYellow=181,137,0
Blue=38,139,210
BoldBlue=38,139,210
Magenta=108,113,196
BoldMagenta=108,113,196
Cyan=42,161,152
BoldCyan=42,161,152
White=147,161,161
BoldWhite=253,246,227

[tomorrow-dark]
BackgroundColour=29,31,33
ForegroundColour=197,200,198
CursorColour=197,200,198
Black=29,31,33
BoldBlack=150,152,150
Red=204,102,102
BoldRed=204,102,102
Green=181,189,104
BoldGreen=181,189,104
Yellow=240,198,116
BoldYellow=240,198,116
Blue=129,162,190
BoldBlue=129,162,190
Magenta=178,148,187
BoldMagenta=178,148,187
Cyan=138,190,183
BoldCyan=138,190,183
White=197,200,198
BoldWhite=255,255,255


[tomorrow-light]
BackgroundColour=255,255,255
ForegroundColour=55,59,65
CursorColour=55,59,65
Black=29,31,33
BoldBlack=150,152,150
Red=204,102,102
BoldRed=204,102,102
Green=181,189,104
BoldGreen=181,189,104
Yellow=240,198,116
BoldYellow=240,198,116
Blue=129,162,190
BoldBlue=129,162,190
Magenta=178,148,187
BoldMagenta=178,148,187
Cyan=138,190,183
BoldCyan=138,190,183
White=197,200,198
BoldWhite=255,255,255
'''

COLOR_NAME_CODES = dict(
    foregroundcolour='10;',
    backgroundcolour='11;',
    cursorcolour='12;',
    black='4;0;',
    red='4;1;',
    green='4;2;',
    yellow='4;3;',
    blue='4;4;',
    magenta='4;5;',
    cyan='4;6;',
    white='4;7;',
    boldblack='4;8;',
    boldred='4;9;',
    boldgreen='4;10;',
    boldyellow='4;11;',
    boldblue='4;12;',
    boldmagenta='4;13;',
    boldcyan='4;14;',
    boldwhite='4;15;',
    x16='4;16;',
    x17='4;17;',
    x247='4;247;',
    x224='4;224;',
    x248='4;248;',
    x249='4;249;',
    x250='4;250;',
    x251='4;251;',
    x252='4;252;',
    x253='4;253;',
    x254='4;254;',
    x255='4;255;',
)

def parse_themes(theme_str):
    def parse_spec(spec):
        x = spec.split('=')
        if len(x) != 2: st()
        name,color = spec.split('=')
        return name,color
    def parse(theme):
        lines = theme.splitlines()
        name = re.search(r'\[(.*)\]', lines[0]).group(1)
        items = dict(parse_spec(l) for l in lines[1:])
        return name,items
    t = [i.strip() for i in theme_str.split('\n\n')]
    return dict(parse(i) for i in t)
    # return [i.splitlines() for i in t][0]

_themes = parse_themes(BUILTIN_THEMES)
__theme_list__ = '\n'.join(_themes)

_TMUX = os.environ.get('TMUX')
ESC_BEGIN = '\033Ptmux;\033\033]' if _TMUX else '\033]'
ESC_END = '\a\033\\' if _TMUX else '\a'

def set_colors(names_colors):
    def _color_spec(name,color):
        return '{}{}{}{}'.format(ESC_BEGIN,COLOR_NAME_CODES[name.lower()],color,ESC_END)
    control_sequence = ''.join(_color_spec(name,color)
            for name,color in names_colors)
    # st()
    print(control_sequence)

def set_theme(theme):
    colors = _themes[theme]
    set_colors(colors.items())


# __theme_list__ = """material-dark
# material-light
# onedark
# solarized-dark
# solarized-light
# tomorrow-dark
# tomorrow-light
# """
# _themes = __theme_list__.splitlines()

commands = ['list', 'set','o']

def match_command(command):
    def match(cmd):
        return cmd.startswith(command)
    fil = [cmd for cmd in commands if match(cmd)]
    return fil

def match_theme(args):
    if len(args) == 1:
        def match(th, theme):
            tps = th.split('-')
            tpd = theme.split('-')
            m = [dest.startswith(s) for s,dest in zip(tps,tpd)]
            # import pdb; pdb.set_trace()
            return all(m)
        return [theme for theme in _themes if match(args[0], theme)]

if __name__ == "__main__":
    # print(parse_themes(BUILTIN_THEMES))
    # exit()
    # print(sys.argv)
    args = sys.argv[1:]
    if len(args) == 0:
        print(__doc__)
    else:
        matched = match_command(args[0])
        if len(matched) > 1:
            print('multi command matched. "{}" from {}'.format(args[0], matched))
        else:
            if len(matched) == 0:
                print('no matched command. "{}" from {}'.format(args[0], commands))
                print('-- try command set instead')
                cmd = 'set'
                # args = sys.argv
            else:
                cmd = matched[0]
                args = args[1:]
            if cmd == 'list':
                print(__theme_list__)
                # print(_themes)
            elif cmd == 'o':
                n = list(COLOR_NAME_CODES.keys())[3:]
                nc = [(k,args[0]) for k in n]
                set_colors(nc)
            elif cmd == 'set' or len(matched) == 0:
                matched = match_theme(args)
                print(matched)
                if len(matched) == 0:
                    print('no matched themes. "{}" from {}'.format(args[0],
                        list(_themes)))
                elif len(matched) > 1:
                    print('multi themes matched. "{}" from {}'.format(args[0], matched))
                else:
                    # print("set " + matched[0])
                    print("set " + matched[0])
                    set_theme(matched[0])
