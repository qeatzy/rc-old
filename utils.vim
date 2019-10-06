func! CmdAlias(lhs, rhs)
" https://vi.stackexchange.com/questions/12872/how-to-make-command-line-abbreviations-that-only-trigger-at-begining-of-line
exec 'cnorea <expr> ' . a:lhs . ' (getcmdtype() == ":" && getcmdline() =~ "^\s*'. a:lhs . '$")?"' . a:rhs . '":"' . a:lhs .'"'
endfunc


" some setting will be overridden by plugins, put those in .postvimrc
" still overridden, eg, ic.
" cp .postvimrc to ~/.vim/after/plugin/postvimrc.vim works (no ., has .vim)
" https://stackoverflow.com/questions/17688232/does-vim-load-plugins-after-loading-vimrc
" :h initialization
" :h scriptnames
" :h after-directory

" {{{ ~/notes/task/vim/remove-comments.vim
func! Op_pos(opfunc)
    " let g:save_pos = getcurpos()
    " mark! o     " :mark does not mark column
    norm! mo
    exec 'set opfunc='. a:opfunc
    return 'g@'
endfunc

func! LineRange(type, ...) abort
    let only_pos = get(a:, 1, 0)
    " echom visualmode() a:type '[]' getpos("'[") getpos("']")
    " echom visualmode() a:type '<>' getpos("'<") getpos("'>")
    if only_pos
        if a:type == 'line' || a:type == 'char'
            return printf("%d,%d", line("'["), line("']"))
        " elseif a:type == 'char'
        "     return line("'[")
        else
            return printf("%d,%d", line("'<"), line("'>"))
        endif
    else
        return (a:type == 'line' || a:type == 'char') ? getline("'[", "']") : getline("'<", "'>")
    endif
endfunc

func! RemoveComments(type, ...) abort
    let lines = LineRange(a:type, 1)
    " echom lines &cms
    let pos = match(&cms, '\s*%s$')
    if pos > 0
        let cms = &cms[pos-1]
        let cmd = printf('%s g+^\s*%s+d_', lines, cms)
        exec cmd
    endif
    norm! `o
endfunc
nmap <silent> ;c mo:set opfunc=RemoveComments<CR>g@
vmap <silent> ;c :<C-U>call RemoveComments(visualmode())<CR>

py <<EOF
import vim
import re

''' 
**notes** all below cases are now handled correctly
error with ~/code/code/code/Lib/site-packages/numpy/distutils/misc_util.py
        """Return the distutils distribution object for self."""

    """
    Return commandline representation used to determine if a file needs
    to be recompiled
    """
''',"""
        simple_fortran_subroutine = '''
        subroutine simple
        end
        '''
""",'''

        f.write(textwrap.dedent("""
            import os
            import sys

            extra_dll_dir = os.path.join(os.path.dirname(__file__), '.libs')

            if sys.platform == 'win32' and os.path.isdir(extra_dll_dir):
                os.environ.setdefault('PATH', '')
                os.environ['PATH'] += os.pathsep + extra_dll_dir

            """))
    def append_to(self, extlib):
        """Append libraries, include_dirs to extension or library item.
        """
error with /home/zyq3e/code/code/code/Lib/site-packages/numpy/distutils/system_info.py
    same case as above
'''

# tested with below 2 files. (in numpy package)
# ~/code/code/code/Lib/site-packages/numpy/distutils/misc_util.py
# ~/code/code/code/Lib/site-packages/numpy/distutils/system_info.py
# correct as long as not use tuple of doc string at same line (or similar rare case), eg
#  ''' some doc ''', """
#   another doc
#  """
# all other cases are handled correctly, eg, 
# some_func("""
#  ....
# """)
def cms_loop_buffer_python(buffer=None, start=None, stop=None):
    # print(len(buffer))
    if stop is None or stop > len(buffer):
        stop = len(buffer)
    if start is None or start < 0:
        start = 0
    # print(buffer[3])
    # del buffer[4:6]
    # b1, b2, b3 = -1, -1, -1
    # log = 'range: {} {}\n'.format(start, stop)
    pat = False
    beg = -1
    lst = []
    for i, line in enumerate(buffer[start:stop]):
        if pat:
            # if True: log += '{:4s} {} {} {} {}\n'.format('flag', beg, i, pat, line)
            m = re.search(pat, line)
            if m:
                pat = False
            continue
        if re.search(r'^\s*#', line):
            # if True: log += '{:4s} {} {} {} {}\n'.format('#', beg, i, pat, line)
            if beg == -1:
                beg = i
            continue
        m = re.search(r'''(['"])\1\1''', line)
        if m:
            # if True: log += '{:4s} {} {} {} {}\n'.format('"""', beg, i, pat, line)
            m2 = re.search(m.group(), line[m.end():])
            if not m2:
                pat = m.group()
            if re.search(r'''^\s*(['"])\1\1''', line):
                if beg == -1:
                    beg = i
                continue
        if beg != -1:
            lst.append((beg,i))
            # log += '{} {}\n'.format(beg, i)
            beg = -1
    # if True: log += '{:4s} {} {} {} {}\n'.format('flag', beg, i, pat, line)
    if beg != -1 and not pat:
        lst.append((beg,stop))
        # log += '{} {}\n'.format(beg, stop)
    for beg, i in reversed(lst):
        del buffer[beg:i]
    # with open('/cygdrive/e/notes/task/vim/xx', 'w') as f:
        # f.write(log)

# adapted from cms_loop_buffer_python()
# tested with ~/notes/task/old/code/ft/SOSystem/birch.h
# ag '^\s*//' $( ag -l '\*/')
def cms_loop_buffer_c(buffer=None, start=None, stop=None):
    # print(len(buffer))
    if stop is None or stop > len(buffer):
        stop = len(buffer)
    if start is None or start < 0:
        start = 0
    # print(buffer[3])
    # del buffer[4:6]
    # b1, b2, b3 = -1, -1, -1
    log = 'range: {} {}\n'.format(start, stop)
    pat = False
    beg = -1
    lst = []
    for i, line in enumerate(buffer[start:stop]):
        if pat:
            if True: log += '{:4s} {} {} {} {}\n'.format('flag', beg, i, pat, line)
            m = re.search(r'\*/', line)
            if m:
                print(m.group(), i, 'end_of_match')
                pat = False
            continue
        if re.search(r'^\s*//', line):
            if True: log += '{:4s} {} {} {} {}\n'.format('#', beg, i, pat, line)
            if beg == -1:
                beg = i
            continue
        m = re.search(r'''/\*''', line)
        if m:
            if True: log += '{:4s} {} {} {} {}\n'.format('"""', beg, i, pat, line)
            m2 = re.search(r'\*/', line[m.end():])
            if not m2:
                pat = True
            if re.search(r'''^\s*/\*''', line):
                if beg == -1:
                    beg = i
                continue
        if True: log += '{:4s} {} {} {} {}\n'.format('last', beg, i, pat, line)
        if beg != -1:
            lst.append((beg,i))
            log += '{} {}\n'.format(beg, i)
            beg = -1
    if True: log += '{:4s} {} {} {} {}\n'.format('flag', beg, i, pat, line)
    if beg != -1 and not pat:
        lst.append((beg,stop))
        log += '{} {}\n'.format(beg, stop)
    for beg, i in reversed(lst):
        del buffer[beg:i]
    with open('/cygdrive/e/notes/task/vim/xx', 'w') as f:
        f.write(log)

EOF

func! RemovePythonComments(type, ...) abort
    let lines = LineRange(a:type, 1)
    keepj py cms_loop_buffer_python(vim.current.buffer, *(int(i)-1 for i in vim.eval('lines').split(',')))
    norm! `o
endfunc

func! RemoveCComments(type, ...) abort
    let lines = LineRange(a:type, 1)
    keepj py cms_loop_buffer_c(vim.current.buffer, *(int(i)-1 for i in vim.eval('lines').split(',')))
    norm! `o
endfunc
" }}} ~/notes/task/vim/remove-comments.vim

" {{{ ~/notes/task/vim/indent-object.vim
" inner indent, i.e. ii. As for ai, see another func, to reduce complexity
" dii delete current indent block, d2ii or 2dii delete parent indent block.
func! IndentObject(cnt, ...) abort
    if a:0 < 2
        let r2 = line('.')
        let r1 = (getline(r2) !~ '^\s*$') ? r2 : search('\S','bcnW')
    else
        let [r1,r2] = a:000[:1]
    endif
    let level = indent(r1)
    if level <= 0
        return
    endif
    let start = r1 - 1
    while start > 0
        if getline(start) !~ '^\s*$' && indent(start) < level
            break

        endif
        let start -= 1
    endwhile

    let len = line('$')
    let stop = r2 + 1
    while stop <= len
        if getline(stop) !~ '^\s*$' && indent(stop) < level
            break
        endif
        let stop += 1
    endwhile
    if a:cnt < 2
        return [level, start, stop]
    else
        return IndentObject(a:cnt-1, start, stop)
    endif
endfunc

func! UseIndentObject(cnt, mode) abort
    try
        let [level, start, stop] = IndentObject(a:cnt)
        if a:mode ==# 'i'
            let [start, stop] = [start+1, stop-1]
        elseif a:mode ==# 'a'
            let stop  -= 1
        elseif a:mode ==# 'I'
            let start += 1
        elseif a:mode ==# 'A'
        endif
        call cursor(start, 1)
        norm! V
        call cursor(stop, 1)
        " norm! o
        " exe "norm! \<Esc>"
    catch /E714/
    endtry
endfunc

onoremap ii :<C-u>call UseIndentObject(v:count1,'i')<CR>
onoremap ai :<C-u>call UseIndentObject(v:count1,'a')<CR>
onoremap ia :<C-u>call UseIndentObject(v:count1,'I')<CR>
onoremap aa :<C-u>call UseIndentObject(v:count1,'A')<CR>
" }}} ~/notes/task/vim/indent-object.vim

