" !printf '\nsource %:p' >> ~/.vimrc  # bootstrap                      
" -- note 1 for linux (eg, ubuntu), 2 for windows, 3 for cygwin, etc.
set nocp
if !exists('g:my_current_platform')     " -- allow overridding for cygwin
    if has("win32unix")
        let g:my_current_platform = 3
    elseif has('win32')
        let g:my_current_platform = 2
    elseif has('unix')
        let g:my_current_platform = 1
    endif
endif

"setup, source cur file + copy rc/after/plugin/cmdline.vim to ~/.vim/after/**
"vc(version-control), see " backup
" backup .vimrc with version control system.
" special char, eg, '<C-k>EC' --  -- 'ESC', '<C-k><C-k><C-k>' --  -- '<C-k>'
" '<C-k><C-m><C-m>' --  -- newline

" fileencoding 是在打开文件的时候，由 Vim 进行探测后自动设置的。因此，如果出现乱码，我们无法通过在打开文件后重新设置 fileencoding 来纠正乱码。
" 编码的自动识别是通过设置 fileencodings 实现的，注意是复数形式。 因此，我们在设置 fileencodings 的时候，一定要把要求严格的、当文件不是这个编码的时候更容易出现解码失败的编码方式放在前面，把宽松的编码方式放在后面。
" 其中，ucs-bom 是一种非常严格的编码，非该编码的文件几乎没有可能被误判为 ucs-bom，因此放在第一位。
" utf-8 也相当严格，除了很短的文件外(例如许多人津津乐道的 GBK 编码的'联通'被误判为 UTF-8 编码的经典错误)，现实生活中一般文件是几乎不可能被误判的，因此放在第二位。
" 如果编码被误判了，解码后的结果就无法被人类识别，于是我们就说，这个文件乱码了。此时，如果你知道这个文件的正确编码的话，可以在打开文件的时候使用 ++enc=encoding 的方式来打开文件，如： :e ++enc=utf-8 myfile.txt     http://edyfox.codecarver.org/html/vim_fileencodings_detection.html
"encoding, mainly for compatibility with file in chinese language
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb2312,gb18030,gbk,cp936,big5,euc-jp,euc-kr,latin1
set fileencoding=utf-8
" scriptencoding utf-8
" set termencoding
" EUC-CN可以理解为GB2312的别名，和GB2312完全相同。
" 微软的CP936通常被视为等同GBK，连 IANA 也以'CP936'为'GBK'之别名。事实上比较起来， GBK 定义之字符较 CP936 多出95字 (15个非汉字及80个汉字) 。 http://blog.wuliaoa.com/?p=503
" GB2312  1980,   GBK  1995,   GB18030-2000,  GB18030-2005
" GB2312有6763个汉字，GBK有21003个汉字，GB18030-2000有27533个汉字，GB18030-2005有70244个汉字。 http://www.fmddlmyy.cn/text24.html
" 从 ASCII、GB2312、GBK 到 GB18030，这些编码方法是向下兼容的。
" BIG5 是通行于台湾、香港地区的一个繁体字编码方案。
" ASCII 、GB2312、GBK、GB18030、unicode、UTF-8字符集编码详解  http://www.cnblogs.com/frankliiu-java/archive/2010/04/01/1702154.html
" What's different between UTF-8 and UTF-8 without BOM?  https://stackoverflow.com/questions/2223882/whats-different-between-utf-8-and-utf-8-without-bom

"profile,
" slow on cygwin, 300 ms vs 600 ms  (pathogen#infect() only vs pathogen+current file)
"   not really   [220 390] ms vs [300 ~ 460]ms. -- cygwin is culprit, not .vimrc
" very fast on linux server without X, 40 ~ 50 ms
" https://stackoverflow.com/questions/1687799/profiling-vim-startup-time"
" https://stackoverflow.com/questions/12213597/how-to-see-which-plugins-are-making-vim-slow
" to lazy InitColor(), do not add to rtp, use Color command to load color dynamicly
"   might not need, `vim --startuptime ~/vimstart.txt` does load any of them.

"text-object
onoremap <silent> af :<C-u>normal! ggVG<CR>
onoremap <silent> if :<C-u>normal! ggVG<CR>
vnoremap <silent> if :<C-u>normal! ggVG<CR>
" d stands for 'def', a function definition.
onoremap id :<C-u>normal! [[V%<CR>

"leader, see also lq, lg, etc for entry point of keymap for prefix 'q', 'g', etc.
" let mapleader = " " 
" 
nnoremap <Space>s :update<CR>
" below caused too many un-wanted saving when pasting with <C-v>
" inoremap <Space>s <C-o>:update<CR><Esc>

let g:pid = getpid()
func! WriteLines(fn, lno, n) abort
    " echo fn
    let _cpo = &cpo
    set cpo-=A
    let range = a:lno . "," . ( a:lno + a:n - 1 )
    " exec "sil! ".  range . 'w !tee &>/dev/null ' . a:fn
    " exec "sil! ".  range . 'w !dd of=' . a:fn . ' &>/dev/null'
    " exec "sil! ".  range . 'w !cat /dev/stdin >' . a:fn
    " echom "sil! ".  range . 'w ' . a:fn
    exec "sil! ".  range . 'w ' . a:fn
    " sleep 10m
    let &cpo = _cpo
endfunc

func! PythonLinesCaputure(lno, n) abort
    " get function name https://vi.stackexchange.com/questions/5501/is-there-a-way-to-get-the-name-of-the-current-funct
    " echo substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '')
    let fn = $HOME . '/.vim/tmp/' . substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '') . g:pid
    call WriteLines(fn, a:lno, a:n)
    exec "sil! r! python3 -d " . fn . " ; rm -f " . fn . " &>/dev/null"
    " exec "sil! r! python3 3-d " . fn
    " exec "sil! !rm -f " . fn
endfunc

let g:scratch = {}
let g:st_winback = v:true
" ech 3 in keys(g:scratch)
" E715 has_key empty
func! WinScratch(...) abort
    let name = a:0 && a:1 != '' ? a:1 : '\[scratch\]' |" '\*scratch\*'
    let cmd = a:0 >= 2 && a:2 != '' ? a:2 : 'split'
    let height = a:0 >= 3 ? a:3 : ''
    let purge = a:0 >= 4 ? a:4 : ''
    " if '' | echo 'yes' | else | echo 'no' |endif
    if !has_key(g:scratch, name)
        exec 'argadd ' . name
        let nr = bufnr(name)
        let g:scratch[name] = nr
        call setbufvar(nr, '&buftype', 'nofile')
        call setbufvar(nr, '&bufhidden', '')
        call setbufvar(nr, '&buflisted', 0)
        call setbufvar(nr, '&swapfile', 0)
        exec 'sil! argdel ' . name
    endif
    let nr = g:scratch[name]
    let wnr = bufwinnr(nr)
    " if wnr == -1
    if winnr('$') == 1
        exec cmd . ' #' . nr
    else
        exec (wnr != -1 ? wnr . 'wincmd w': 'wincmd w | b ' . nr) 
    endif
    if height != '' && winnr('$') > 1
        exec (cmd =~ 'vs\(plit\)\?' ? 'vert res ' : 'res ') . height
    endif
    if purge > 0 | exec (purge > 1 ? 'undo 0' : 'sil! e') | endif
endfunc

func! InitWinScratch() abort
    nn <buffer> ;s :<C-u>call WinScratch('','edit',g:sz_scratch,1+v:count)<CR>
    " nn <buffer> ;e :<C-u>set ft=dirvish<CR>
endfunc

let g:sz_scratch = ''
nn ;s :<C-u>call WinScratch('','edit',g:sz_scratch)<CR>
augroup win_scratch
    au!
    if v:version >= 704
    autocmd OptionSet buftype if v:option_new == 'nofile' | call InitWinScratch() 
    endif
augroup END |" win_scratch

let g:cpurge = 1
func! BashLinesCapture(lno, n) abort
    " get function name https://vi.stackexchange.com/questions/5501/is-there-a-way-to-get-the-name-of-the-current-funct
    " echo substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '')
    let fn = $HOME . '/.vim/tmp/' . substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '') . g:pid
    call WriteLines(fn, a:lno, a:n)
    call WinScratch('','',g:sz_scratch, exists('b:cpurge') ? b:cpurge : g:cpurge)
    exec "sil! r! bash " . fn . " ; rm -f " . fn . " &>/dev/null"
    " exec "sil! r! bash " . fn
    " exec "sil! !rm -f " . fn
    if g:st_winback
        winc p
    endif
endfunc

" See also shellescape(), eg, let cmd = shellescape(join(getline(a:firstline,a:lastline), "\n"),1), other item that might be of interest is v:count, func-range, and function-range-example.
" https://vi.stackexchange.com/questions/13905/how-to-disable-expansion-of-percent-sign-in-cmdline-and-exec
func! Run_lines_as_shell_cmd(lno, n) abort
    let cmd = shellescape(join( getline(a:lno, a:lno + a:n - 1), "\n"),1)
    exec "!bash -c ".cmd
    " exec   range . 'w !tee |bash /dev/stdin'
endfunc
nnoremap qr :<C-u>call Run_lines_as_shell_cmd(line('.'),v:count1)<CR>
nnoremap gr :<C-u>call BashLinesCapture(line('.'),v:count1)<CR>
" nnoremap <F3> :<C-u>call PythonLinesCaputure(line('.'),v:count1)<CR>
" nnoremap qr :.w !sed 's/^\$\s*//' \|bash -o pipefail<CR>
" nnoremap qr :.w !sed 's/\r$// ; s/^\s*\$\s*\(.*\)\s*/\1/' \|bash -o pipefail<CR>
" -- sed fails on dos fileformat, "h du" become "h $'du\r'",  "du --help" become "du $'--help\r'".  --  detected by add bash -x to qr nnoremap.
" vnoremap qr :w !bash -euo pipefail<CR>
vnoremap qr :<C-u>call Run_lines_as_shell_cmd(line("'<"),line("'>")-line("'<")+1)<CR>
vnoremap gr :<C-u>call BashLinesCapture(line("'<"),line("'>")-line("'<")+1)<CR>
" for bash fail fast is suggested, 'set -u' 'set -e' 'set -o pipefail'
" also, to customize invoked bash, set env BASH_ENV to rc file for non-interactive use of bash.
" TODO: add 'if' for uname 
"run apps, "launch, eg. bash, see " env " eval
nnoremap ,r :exec '!bash -ceuo pipefail '.shellescape(getline('.'),' ()').' &> ~/.tmprun'<CR>:redraw!<CR>:tabe ~/.tmprun\|e<CR>
" nnoremap ,r :exec '!'.getline('.').' > ~/.tmprun'<CR>:redraw!<CR>:e ~/.tmprun<CR>
"nnoremap [r :exec '!'.getline('.').' > ~/.tmprun'<CR>:redraw!<CR>:e ~/.tmprun<CR>
nnoremap [r :exec '!bash -ceuo pipefail '.shellescape(getline('.'),' ()').' > ~/.tmprun'<CR>:redraw!<CR>:e ~/.tmprun<CR>
" mcd
"< Sure thing, you can 'write' any content of the current file into the stdin of another program: `:.w !bash`.  http://stackoverflow.com/a/19883963/3625404
"for why/how to use shellescape, see http://stackoverflow.com/questions/15394572/escaping-in-vim-when-shelling-out-so-its-not-expanded-to-filename
nnoremap [w :exec '!whatis '.shellescape(expand('<cword>'))<CR>
nnoremap ,b :!bash %:p<CR>
nnoremap \f :exec 'r!ls -A '.g:notesBaseDir<CR>
nnoremap \p :r!find ~/.vim/bundle -type d<CR>
nnoremap \p :r!ls ~/.vim/bundle<CR>
vnoremap $ $h
"shell
set shell=bash  " shellcmdflag
" nnoremap <C-d> :sh<CR>
"lq, qj (qk, qm, qh) ql qg q f qi q; q: q/ q'
" nnoremap qi :.r!bash -euo pipefail getline('.')<CR>
" nnoremap qi :.!bash -euo pipefail pwd<CR>
" nnoremap qi :echo getline('.') \|!bash -euo pipefail<CR>
" r !pwd
"lg, g/ (alias for gc comment)
"lz,
"l,, 
"lb, (b for backslash)
nnoremap \k :exec '!pydoc ' . shellescape(expand('<cWORD>') . ' <bar>less'<CR>
nnoremap \k :exec 'silent !pydoc '.shellescape(expand("<cWORD>")).' > '.g:my_tmpdoc<CR>
let g:my_tmpdoc = '~/.tmpdoc'
let g:my_doc_program = 'man '
let g:my_doc_program_suffix = ''
nnoremap qk :exec 'silent !'.g:my_doc_program.shellescape(expand('<cWORD>'),1).' '.g:my_doc_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
" nnoremap qj :exec 'silent !'.g:my_doc_program.shellescape(expand('<cword>')).' '.g:my_doc_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
nnoremap qj :exec 'silent !'.g:my_doc_program.shellescape(expand('<cword>'),1).' '.g:my_doc_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
nnoremap ql :<C-u>e .<CR>
" nnoremap ql :Explore<CR>
let g:my_man_program = 'man '
let g:my_man_program_suffix = ''
nnoremap [v :exec '!'.g:my_man_program.shellescape(expand('<cWORD>')).' '.g:my_man_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
nnoremap qm :exec '!'.g:my_man_program.shellescape(expand('<cword>')).' '.g:my_man_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
" nnoremap <Leader>m :exec 'verbose map ' expand('<cWORD>')<CR>
nnoremap <Space>n :exec 'map ' expand('<cWORD>')<CR>

" command! -range R exec join(getline(<line1>,<line2>),"\n")
func! Run_lines_as_vimscript() range abort
    " the problem & advantage is run in func scope, global variable not affected.
    exec join(getline(a:firstline, a:lastline),"\n")
endfunc

" execute select vimscript code in global scope, use :exec, :join and :getline.
" early version use "<bar>" instead of "\n", which cause E488 Error
nnoremap <silent> <space>r :call Run_lines_as_vimscript()<CR>
vnoremap <silent> <space>r :call Run_lines_as_vimscript()<CR>
vnoremap <F2> :<c-u>exec join(getline("'<","'>"),"\n")<CR>
nnoremap <silent> <F2> :<C-u> exec v:count1 == 1 ? getline('.') : join(getline('.',line('.')+(v:count1-1)), "\n") <CR>

" <M-s> in vim's insert mode type <C-v> (or <C-q>), then type <M-s>, see what is inserted.
inoremap s <Esc>:up<CR>
nnoremap s :up<CR>
" If 't_vb' is cleared and 'visualbell' is set, no beep and no flash will ever occur.  http://vim.wikia.com/wiki/Disable_beeping
" belloff errorbells visualbell t_vb
" gvim disable bell.  https://stackoverflow.com/questions/18589352/cant-get-bells-to-disable
" cmdline related key maps
" set cedit
"cmdline, see " rc/after/plugin/cmdline.vim 'b' is got via type <C-v> (or <C-q> on windows) in insert mode.
" ln -s ~/notes/rc/after ~/.vim
noremap! b <S-Left>|" <Alt-b> move word back        -- both insert and cmdline mode
noremap! f <S-Right>|" <Alt-f> move word forward
inoremap <C-f> <Right>
inoremap <C-b> <Left>
nnoremap q; q:k
nnoremap ; :
" cnoremap ; <C-e><C-u><Esc><Esc><Esc>
" extra <C-h> is a fix for cancel increment search, otherwise the previous pattern is located.
cnoremap ; <C-e><C-u><C-h><Esc><Esc><Esc>
" <C-j> <C-k> rc/after/plugin/cmdline.vim
" cnoremap <C-j> <Down>
" cnoremap <C-k> <Up>
cnoremap <C-y> <Down>
" seems <C-h> and <BS> are indisguishable at some terminal vim.
" cnoremap <BS> <C-b>
cnoremap <C-o> <S-Tab>
" cnoremap <C-l> <C-e>

" has() executable()
" I do a bunch of customization of my .vimrc, but it's all based on capabilities, rather than platform. I check for the different has("gui_*") flags, and also check has("unix"). This way I avoid dealing with messy platform dependent path issues.  https://stackoverflow.com/a/3291710/3625404
" has("win32")  has("unix")  has("mac")  has("win32unix")  isdirectory(dir)  filereadable(file)  has("gui_running")  hostname()  !uname
" h feature-list
"system-dependent setting for working directory,  os -- if linux then distro, uname, 
"platform, see " source
"if system('uname')[0:4] == 'Linux'
"    set cdpath+=
" instead of test uname, set global variables in ~/.vimrc, and test here.
let g:my_tmpdoc = '~/.tmpdoc'
if g:my_current_platform == 2       " windows
    let g:notesBaseDir = 'e:/notes/'
    let g:Option_clipboard = 'unnamed'
elseif g:my_current_platform == 3   " cmder, cygwin
    " cygwin
    " note dir could be same as linux, if a symlink was created properly.
    " but clipboard should conform to windows.
    let g:notesBaseDir='/cygdrive/e/notes/'
    let g:Option_clipboard = 'unnamed'
    let g:ff_browser='/cygdrive/d/pkg/dt/firefox/firefox.exe '
    let g:my_tmpdoc = '/cygdrive/C/Users/Dell/.tmpdoc'
elseif g:my_current_platform == 5   " babun, cygwin
    let g:notesBaseDir='/cygdrive/e/notes/'
    let g:Option_clipboard = 'unnamed'
    let g:ff_browser='/cygdrive/d/pkg/dt/firefox/firefox.exe '
elseif g:my_current_platform == 7   " MobaXterm, cygwin
    let g:notesBaseDir='/cygdrive/e/notes/'
    let g:Option_clipboard = 'unnamed'
else                                " linux
    let g:notesBaseDir='~/notes/'
    let g:Option_clipboard = 'unnamedplus'
    let g:ff_browser='firefox '
endif 

"option, see " 
" toggle boolean option, refto http://vim.wikia.com/wiki/Quick_generic_option_toggling
"nnoremap <F11> :set wrap! wrap?<CR>
" function of map key to toggle option
function! MapToggle(key, opt)
    let cmd = ':set ' . a:opt . '! \| set ' . a:opt . "?\<CR>"
    exec 'nnoremap ' . a:key . ' ' . cmd
    exec 'inoremap ' . a:key . " \<C-O>" . cmd
endfunction
command! -nargs=+ MapToggle call MapToggle(<f-args>)
" Display-altering option toggles
MapToggle \w wrap
MapToggle ,w wrap
"MapToggle <F3> list

"init, see "" ls
" 'path' is global or local to buffer, global-local
:exec 'set path +='.expand(g:notesBaseDir)
let s:oldcwd =  getcwd()
let $RC_ROOT=expand('<sfile>:p:h')
source $RC_ROOT/.utility.vim
" call utils#init()
so /cygdrive/e/notes/task/install/vim/dev/plugin/a.vim
" source $RC_ROOT/utils.vim
" exec 'lcd' fnameescape(s:oldcwd)
" -- cd then source used instead of exec source,
"  for 'include' and [^i ^w^i [I [i to work properly.
" :exec 'source <sfile>:p:h/.utility.vim'
let s:JJJJJ = expand('<sfile>:p:h')
func! _R()
    exec 'source '.s:JJJJJ.'/postvimrc.vim'
    " ln -s postvimrc.vim ~/.vim/after/plugin/postvimrc.vim    # cannot stat './.postvimrc': Too many levels of symbolic links
    " ln -s $(realpath postvimrc.vim) ~/.vim/after/plugin/postvimrc.vim
endfunc
command! -nargs=0 R call _R()
" echo 'fin'
" R


" no backup, set directory for swap file, '//' at the end of directory
"+ tell vim to use the absolute path to create swap file 
"+ set undofile directory, vim 7.3+
"backup, see " vc(version-control)
set nobackup swapfile undofile
set directory=~/.vim/.vimswap//      " comma separated string, first usable one will be used. directory ending with '//' using full pathname.
set undodir=~/.vim/.vimundo//
" set magic wrapscan
"case, see " search
set ignorecase smartcase
set nohlsearch incsearch
" MapToggle <F1> hlsearch
set hidden
set autoread
set noautochdir
"an alternative of autochdir, if some plugin complains, see http://vim.wikia.com/wiki/Set_working_directory_to_the_current_file
"+ autocmd BufEnter * silent! lcd %:p:h
set history=10000
set timeout|"-- default on
set timeoutlen=200
set ttimeout|"-- default off
set ttimeoutlen=100
		" ttimeoutlen	mapping delay	   key code delay	~
		"    < 0		'timeoutlen'	   'timeoutlen'
		"   >= 0		'timeoutlen'	   'ttimeoutlen'
" augroup timeout
"     autocmd!
"     autocmd InsertEnter * set timeoutlen=200
"     autocmd InsertLeave * set timeoutlen=1000
" augroup END
"set wildmode=full wildmenu
exec 'set clipboard='.g:Option_clipboard
nnoremap ;z :call Toggle_clipboard()<CR>:set clipboard?<CR>
func! Toggle_clipboard()
    if &clipboard == 'unnamedplus'
        set clipboard =autoselect,exclude:cons\|linux
    else
        set clipboard =unnamedplus
    endif
endfunc
" clipboard=autoselect,exclude:cons\|linux
"         Last set from ~/.vim/bundle/vim-surround/plugin/surround.vim

"suffixes, from $VIMRUNTIME/debian.vim, see " file
" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
" set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set suffixes +=.html,.js,.png,.jpg,.bks
"ignore, see " message
" wildignore wildchar suffixes shortmess
" To completely ignore files with some extension use 'wildignore'.

"message, see " ignore
    " stl(statusline)
set shortmess+=I    " no intro message when start vim
"set shortmess=atI " 启动的时候不显示那个援助乌干达儿童的提示 

"plugin
" try plugin manager, pathogen, vundle, VAM
"+ try pathogen
" execute pathogen#infect()
filetype plugin indent on
syntax enable   " syn-on
" above line a shortcut of two line, one for plugin, one for indent
" call pathogen#helptags() "If you like to get crazy :)
" If you don't like to get crazy, only call :Helptags when you need to.
" Plugins are then added to ~/.vim/bundle.

"indent-option, see " fmt
set tabstop=4       |" Number of spaces that a <Tab> in the file counts for. eg, used for print.
set shiftwidth=4    |" used by '=' and '<' '>' to format indent.
set softtabstop=4   |" used by <BS> in insert mode, and <Tab> for insert tab. If 'smarttab' is on, shiftwidth is used instead.
" set smarttab        |" default off. if on use shiftwidth for <BS>, if off use softtabstop.
set expandtab       |" expand tab for both inserting <Tab> in insert mode, and '=' '>' '<' commands.
set autoindent      |" inherit indent of previous line
set shiftround      |" round space to multiple of shiftwidth
" :retab
set backspace=indent,eol,start   " Set for maximum backspace smartness

"fmt, "format, see " indent
set textwidth=82
vmap Q gq
nmap Q gqap
"reformat code, or better, '=if' or '=af' after onoremap af :<C-u>normal! ggVG<CR>
nnoremap \p gg=G``
" Related, if you open a file that uses both tabs and spaces, assuming you've got
"+ set tabstop=4 shiftwidth=4 expandtab autoindent
"+ You can replace all the tabs with spaces in the entire file with
"+ :%retab
"html indent not include some common tags, in vim 7.4 as default
" a workaround for that, refto http://stackoverflow.com/questions/19323607/html-indenting-not-working-in-compiled-vim-7-4-any-ideas
" let g:html_indent_script1 = "inc"
" let g:html_indent_style1 = "inc" 
"+ let g:html_indent_inctags = "html,body,head,tbody"
let g:html_indent_inctags = " head,tbody"
":h html_indent_inctags 
":echo html_indent_inctags 

func! DeleteCurBufferNotCloseWindow() abort
    if &modified
        echohl ErrorMsg
        echom "E89: no write since last change"
        echohl None
    elseif winnr('$') == 1
        bd
    else  " multiple window
        let oldbuf = bufnr('%')
        let oldwin = winnr()
        while 1   " all windows that display oldbuf will remain open
            if buflisted(bufnr('#'))
                b#
            else
                bn
                let curbuf = bufnr('%')
                if curbuf == oldbuf
                    enew    " oldbuf is the only buffer, create one
                endif
            endif
            let win = bufwinnr(oldbuf)
            if win == -1
                break
            else        " there are other window that display oldbuf
                exec win 'wincmd w'
            endif
        endwhile
        " delete oldbuf and restore window to oldwin
        exec oldbuf 'bd'
        exec oldwin 'wincmd w'
    endif
endfunc

func! Buffer_left_0_right_1(cnt, is_right)
    exec a:cnt a:is_right ? 'bn' : 'bp'
endfunc

"buffer, see " window " ctrlp " fzf
" nnoremap <Space>b :call DeleteCurBufferNotCloseWindow()<CR>
" nnoremap \b :bd #<CR>
" nnoremap <Space>; :bm<CR>
" nnoremap <Space>m :bm<CR>
" reload and force reload
nnoremap <space>g :e<CR>
nnoremap \g :e!<CR>
nnoremap <Space>h :<c-u>call Buffer_left_0_right_1(v:count1, 0)<CR>
nnoremap <Space>l :<c-u>call Buffer_left_0_right_1(v:count1, 1)<CR>

func! Buf_go_buffer(count) abort
    let l:count = (a:count == 0)? bufnr('#') : a:count
    if l:count == -1 || l:count == bufnr('%')
        return
    endif
    exec 'b '.l:count
    if &bt != 'terminal'
        norm! `t
    endif
endfunc
"buffer-switching, for a plugin with file completion if no match, see http://vi.stackexchange.com/a/2187
" switch to Nth buffer or alternate buffer if no count is given, and restore cursor.
" autocmd BufLeave * mark t
autocmd BufLeave * norm! mt
nnoremap <silent> gt :<C-u>call Buf_go_buffer(v:count)<CR>|" alternatives: gh
nnoremap <silent> gh :<C-u>call Buf_go_buffer(v:count)<CR>|" alternatives: gh
nnoremap g0 :bfirst<CR>
nnoremap g9 :blast<CR>
" buffer-option
" buflisted, affect :ls
"autocmd mark statements causing problems with nerd tree and netrw? http://vi.stackexchange.com/questions/8183/autocmd-mark-statements-causing-problems-with-nerd-tree-and-netrw

"pm, "pn, "permission, modifiable/readonly/etc
" nnoremap zp :set modifiable! readonly!<CR>

"cd, see " 
" Change Working Directory to that of the current file
cnoremap cwd lcd %%
cnoremap cd. lcd %%

"sudo, see "
cnoremap w!! w !sudo tee % >/dev/null

func! WinSwapNWinSize()
    " start from last window, gradually join two into one unit.
endfunc

func! WinSwap2WinSize()
    if winnr('$') == 2
        let [h1,w1] = [winheight('.'),winwidth('.')]
        winc x
        let [h2,w2] = [winheight('.'),winwidth('.')]
        echo [h1,w1,h2,w2]
        if h1 == h2
            exec w1 'wincmd |'
        else
            exec 'res' h1 
        endif
    endif
endfunc

" https://stackoverflow.com/questions/1269603/to-switch-from-vertical-split-to-horizontal-split-fast-in-vim?rq=1
" https://superuser.com/questions/330198/how-can-i-set-gvims-window-width-to-80-columns-of-text-plus-the-ones-needed-to
" echo winwidth(0)    |" full width
" numberwidth
" https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
" set lines=50 columns=100  " gvim, set the default window size
" https://stackoverflow.com/questions/594838/is-it-possible-to-get-gvim-to-remember-window-size
" window-option
set noequalalways
" set eadirection
set winminwidth=0
set winminheight=0
set winwidth=1 " or set to 110 or 999 to always max width current window.
"window, see " buffer
nnoremap <C-w><C-e> :<C-u>call WinSwap2WinSize()<CR>
nnoremap <silent> <C-h> :if winnr('$') == 1\|tabp\|else\|winc h\|endif<CR>
nnoremap <silent> <C-l> :if winnr('$') == 1\|tabn\|else\|winc l\|endif<CR>
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap go <C-w><C-w>
nnoremap goo <C-w>W|" ,w too at older time.
nnoremap gjj <C-w><C-x>
" vertical resize, z0<CR> minimize, z=equalize, z99<CR> maximize.
nnoremap z= <C-w>=
nnoremap <silent> ,s :sp<CR>
nnoremap <silent> ,v :vs<CR>
" nnoremap ,d :call DoWindowSwap()<CR>
" nnoremap ,z :call MarkWindowSwap()<CR>
"window,"vsplit
set splitright     " Puts new vsplit windows to the right of the current
" set splitbelow     " Puts new split windows to the bottom of the current
nnoremap <Space>f :set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>
nnoremap \a :pclose<CR>
nnoremap qp :pclose<CR>

nnoremap <C-w>e :<C-u>call SwapWindowLayout()<CR>
func! SwapWindowLayout() abort
    if winnr('$') < 2
        return
    endif
    let curwin = winnr()
    let destwin = winnr('#')
    if destwin == 0 || destwin == curwin
        let destwin -= 1
        if destwin == 0
            let destwin = winnr('$')
        endif
    endif
    let g:markedWin1 = curwin
    let g:markedWin2 = destwin
    call DoWindowSwap()
endfunc

map q <Nop>
" nnoremap q :if winnr('$') > 1 \|hide\|else\|qall\|endif<CR>
" bug: below function make CPU usage over 10% on cygwin 64, win 10. Or big file's fault?
func! Hide_cur_window_or_quit_vim(count) range abort
    if winnr('$') == 1
        qall    " E173: more files to edit
        return
    endif
        try
            exec (a:count > 1 ? a:count : '') 'hide'
        catch
            echohl Error
            echom "error! v:count == ".v:count ' -- func! Hide_cur_window_or_quit_vim'
            echohl None
        endtry
endfunc
func! HideAlternateWindow() abort
    exec winnr('#') 'hide'
endfunc
nnoremap <silent> q :<C-u> call Hide_cur_window_or_quit_vim(v:count)<CR>
nnoremap <silent> qq :<C-u> call Hide_cur_window_or_quit_vim(v:count)<CR>
nnoremap <silent> q0 :<C-u>call HideAlternateWindow()<CR>
nnoremap qo <C-w><C-o>
augroup CmdlineWindow
    autocmd!
    " E11
    autocmd CmdwinEnter * nnoremap q :q<CR>
augroup END
" echo winnr('#') winnr() winnr('$')    -- now in 'statusline'

cno <silent> <expr> <c-x> '<c-a>'.timer_start(0, {-> setreg('+', substitute(getcmdline(), ' \\|\(^\w\+ \)\\|^', "\n", 'g')."\n\n", 'l') + feedkeys('<c-u><c-c>', 'int') })[-1]|"-- https://vi.stackexchange.com/a/14392/10254
"complete, see " 
set dictionary=~/notes/enDict.txt   |" List of file names used for i^x^k . 
set complete-=i " Don't scan includes, since it can be very slow.
" inoremap <C-f> <C-x><C-f>

"invocation(startup), useful settings, see "" ls
"" viminfo, see :h viminfo-file-name and :h wviminfo
"+ option chars, n for name must be last, 
set viminfo='1024,f1,%1024,h
" let &vif=$HOME . '/.vim/.viminfo'
"" save different buffer list for different directories,
"+ by setting a local 'viminfo' file. refto 
"+ http://vim.wikia.com/wiki/Vim_buffer_FAQ and 
"+ http://www.vim.org/scripts/script.php?script_id=441
"+ below are excerpt show the basic idea
"set viminfo='1025,f1,%1024
"call SetLocalOptions(".")

"session(session/viminfo/modeline), see "" ls
" Vim Modeline Vulnerabilities  https://security.stackexchange.com/questions/36001/vim-modeline-vulnerabilities
" https://stackoverflow.com/questions/8854371/vim-how-to-restore-the-cursors-logical-and-physical-positions
" au BufWinLeave *.plg mkview
" au VimEnter *.plg loadview

" func! WipeNetrwBuffer()
func! RemoveNoFileBuffer()
    for i in range(1,bufnr('$'))
        " if buflisted(i) && (isdirectory(bufname(i)) || getbufvar(i,'&ft') == 'netrw')
        let bname = bufname(i)
        if buflisted(i) && (isdirectory(bname) || (bname[0] != '[' && !filereadable(bname)))
            exec 'bd' i
        endif
    endfor
endfunc

"quit, "exit, see "" ls
nnoremap \q :q!<CR>
func! Clean_for_VimLeavePre()
    b1 
    if line2byte(line("$"))+col("$") < 100000 " less than 100KB
        %y y
    endif
    " call WipeNetrwBuffer()
    call RemoveNoFileBuffer()
endfunc
autocmd! VimLeavePre
" autocmd VimLeavePre * call writefile([v:dying], '/tmp/some_file', 'a')
autocmd VimLeavePre * call Clean_for_VimLeavePre()
" autocmd! VimLeavePre
" autocmd VimLeavePre |" This is executed only once,
" You might already have a VimLeave auto command defined somewhere, which will take precedence; futher ones won't be executed. :au vimleave to see what's already defined. Try au! vimleave before defining your autocmd to delete any existing ones. - Antony Jul 20 '16 at 16:17 https://vi.stackexchange.com/q/8869/10254

" https://stackoverflow.com/a/4671105/3625404
" func! MatchCount()
"     let res = Capture("%s///gne")
"     return matchstr(res, '\d*')
" endfunc
let s:prevcountcache=[[], 0]
function! ShowCount(...)
    let key=[@/, b:changedtick]
    if s:prevcountcache[0]==#key
        return s:prevcountcache[1]
    endif
    let s:prevcountcache[0]=key
    let s:prevcountcache[1]=0
    let pos=getpos('.')
    try
        let result = 0
        if @/ != ''
            redir => subscount
            silent %s///ne
            redir END
            let result=matchstr(subscount, '\d\+')
        endif
        let s:prevcountcache[1]=result
        return a:0==0 ? result : (result <= a:1 ? result : a:1)
    finally
        call setpos('.', pos)
    endtry
endfunction

" return count of current paragraph if inside, count of previous and next if between.
"   paragraph seperated by '(^$)\+', not "^\s\+$".
func! LineCountCurrentParagraph()
    return line("'}") - line("'{") + ((match(getline("'{"),'^\s*$') == -1) + (match(getline("'}"),'^\s*$') == -1) -1)
endfunc

" echo len(getbufinfo({'buflisted':1})) |" count buffers. https://superuser.com/a/1221514/487198

" count modified buffers. https://vi.stackexchange.com/questions/14311/vim-count-how-many-buffers-been-modified/14313#14313
if exists('*getbufinfo')          " v:version >= 704
func! CountModifiedBuffer()
    return len(filter(getbufinfo(), 'v:val.changed == 1'))
    " let mod = map(getbufinfo(), 'v:val.changed')
    " return len(filter(mod, 'v:val'))
endfunc
elseif exists('*getbufvar')
func! CountModifiedBuffer()
    return len(filter(range(1, bufnr('$')), 'getbufvar(v:val, "&mod")'))
endfunc
endif

" [+] if only current modified, [+3] if 3 modified including current buffer.
" [3] if 3 modified and current not, "" if none modified.
func! IsBuffersModified()
    let cnt = CountModifiedBuffer()
    return cnt == 0 ? '' : ( &modified ? ( '[+'. ( cnt > 1 ? cnt : '') . ']' ) : ( '['.cnt.']' ) )
endfunc

func! WinNumberStatus()
    return winnr('$') == 1 ? "": winnr().'-'.winnr('$')
endfunc

" set statusline=%2*%n\|%<%*%-.40F%2*\|\ %2*%M\ %3*%=%1*\ %1*%2.6l%2*x%1*%1.9(%c%V%)%2*[%1*%P%2*]%1*%2B
" --also try above setting, when you have time.
set showmatch showmode showcmd
set ruler		" show the cursor position all the time
"set cmdheight =2
set laststatus =2   " 2: always, 0: never, 1: if winnr('$') >= 2.
"     %-0{minwid}.{maxwid}{item}  %= split left right, %< truncate,
"         (...%) group, %{} eval in window, %! eval in window + buffer.
" set stl=[%n]%.20f[%l/%L][%c%V][%a]%=%r%m[%o][%p,%P]
"stl, "statusline, -- for startup, see " invoke " message
" qf setlocal stl=%t%{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l/%L,%c%V%)\ %P
" $VIMRUNTIME/ftplugin/qf.vim
if version >= 700
    au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
    au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif
set statusline=
set statusline+=%7*\[%n]                                  " buffernr
set statusline+=%1*%-10.30f\                                " File+path
set statusline+=%2*%<\ %y\                                  " FileType
set statusline+=%3*\ %{''.(&fenc!=''?&fenc:&enc).''}      " Encoding
set statusline+=%3*\ %{(&bomb?\",BOM\":\"\")}\            " Encoding2
set statusline+=%4*\ %{(&ff==\"unix\"?\"\":&ff)}\                              " FileFormat (dos/unix..) 
"set statusline+=%5*\ %{&spelllang}\%{HighlightSearch()}\  " Spellanguage & Highlight on?
"set statusline+=%5*\ %{HighlightSearch()}\  " Spellanguage & Highlight on?
" set statusline+=%{strftime(\"%H:%M\")}
set statusline+=%8*\ %=%-10{WinNumberStatus()}\ %l/%L\ [%02p%%]  " winnr, Rownumber/total (%)
" set statusline+=%9*\ col:%03c\                            " Colnr
set statusline+=%9*\ %03c\                            " Colnr
set statusline+=%{LineCountCurrentParagraph()}
" set statusline+=%0*\ %m%r%w\ %P\                      " Modified? Readonly? Top/bot.
set statusline+=%0*\ %{IsBuffersModified()}%r%w\ %P\                      " Modified? Readonly? Top/bot.
" set statusline^=[%n]
set statusline^=%{ShowCount(999)}
" helper
function! HighlightSearch()
    if &hls
        return 'H'
    else
        return ''
    endif
endfunction

func! REPL_SendLines(...) abort
    let terms = term_list()
    if len(terms) == 0
        echoerr 'No running terminal'
        return
    elseif len(terms) > 1
        echoerr 'More than one terminal'
        return
    endif
    let buf_term = terms[0]
    " echo terms type(terms) buf_term
    " return
    let line = get(a:, 1, '.')
    let line2 = get(a:, 2, '')
    if line2 == ''
        call term_sendkeys(buf_term, getline(line)."\<CR>")
        call term_wait(buf_term, 50)
    else    " to fix: the output might overlap, possibly due to async nature.
        " echo join(getline(line, line2), "\n")
        " call term_sendkeys(buf_term, join(getline(line, line2), "\<CR>")."\<CR>")
        " call term_wait(buf_term, 50)
        for i in range(line, line2)
            call term_sendkeys(buf_term, getline(i)."\<CR>")
            call term_wait(buf_term, 5)
        endfor
    endif
endfunc

"terminal,
if has('terminal')
if exists('+termkey')
set termkey=<C-L>
else
set termwinkey=<C-L>
endif
" let &termkey='[1;5n'  "<C-.>
" let &termkey='.'  "<M-.>
tnoremap gt <C-l>:b #<CR>
tnoremap <C-o> <C-w>N
tnoremap jk <C-l>N
" below a fix for zsh's "kj" vi-cmd-mode
tnoremap kj <C-[>
call CmdAlias('term',' term ++curwin')
call CmdAlias('ter',' term ++curwin')
endif

" call InitColor('~/.vim/colors')
" echo fnamemodify('~/.vim/colors', ':p:h:h')
"
func! InitColor(...)
    for path in a:000
        let fns =globpath(path, "**/colors", 0,1)
        for fn in fns | exec 'set rtp+='.fnamemodify(fn, ':p:h:h') | endfor
    endfor
endfunc

" enable 256-color console Vim syntax highlight in ConEmu
" from http://conemu.github.io/en/VimXterm.html
if !has("gui_running")
    set term=xterm
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    " color seoul256
endif
set bg=light
" peaksea
" xoria256
" set t_Co=256
if g:my_current_platform == 2   " windows
    color morning
elseif g:my_current_platform == 3   " cygwin
    " color molokai
    " color xoria256  " solarized
else    " odd number for linux
    color default
endif
"color, see " highlight
call InitColor('~/.vim/colors')
nnoremap qg :call TogBG()<CR>
" goyo.vim https://github.com/junegunn/goyo.vim
" autocmd! User GoyoEnter Limelight
" autocmd! User GoyoLeave Limelight!
" hi User1 guifg=#ffdad8  guibg=#880c0e
" hi User2 guifg=#000000  guibg=#F4905C
" hi User3 guifg=#292b00  guibg=#f4f597
" hi User4 guifg=#112605  guibg=#aefe7B
" hi User5 guifg=#051d00  guibg=#7dcc7d
" hi User7 guifg=#ffffff  guibg=#880c0e gui=bold
" hi User8 guifg=#ffffff  guibg=#5b7fbb
" hi User9 guifg=#ffffff  guibg=#810085
" hi User0 guifg=#ffffff  guibg=#094afe

func! ExtractURLThenOpenInBrowser()
    " nnoremap ,x :let @j = '^\%(链接：\)\?["''()]*\([^'']\{-}\))\?[.,]\?$'<CR>:let @k = substitute(expand('<cWORD>'),@j,'\1','')<CR>:exec 'silent !'.g:ff_browser.shellescape(@k,1)<CR>:redraw!<CR>
    let word = expand('<cWORD>')
    " echo match('https://github.com', '^https\?:\/\/')
    if match(word, '^https?:\/\/')
        exec 'silent !'.g:ff_browser.shellescape(word,1)
    " else " inside of parentheses, eg 字符(p.nju.com)字符
    endif
endfunc

"url, "browser, "web, "firefox, see " gf
"www, web/browser/search-engine related, eg, pipe to firefox, embed w3m for simple search/etc.
" nnoremap zj :exec 'silent !firefox --browser https://docs.python.org/2/library/'.shellescape(expand('<cWORD>')).'.html'<CR>:redraw!<CR>
" nnoremap zj :exec 'silent !firefox --browser https://docs.python.org/2/library/'.shellescape(expand('<cword>')).'.html'<CR>:redraw!<CR>
nnoremap ,x :exec '!xdg-open '.shellescape(expand('<cWORD>',1))<CR>:redraw!<CR>
" remove leading paren or single quote, trailing paren or quote and possibly comma or dot.
nnoremap ,x :let @j = '[''()]*\([^''(),]*[^.),]\).*'<CR>:let @k = substitute(expand('<cWORD>'),@j,'\1','')<CR>:exec 'silent !'.g:ff_browser.shellescape(@k,1)<CR>:redraw!<CR>
nnoremap ,x :let @j = '^["''()]*\([^'']\{-}\)[.,]\?)\?$'<CR>:let @k = substitute(expand('<cWORD>'),@j,'\1','')<CR>:exec 'silent !'.g:ff_browser.shellescape(@k,1)<CR>:redraw!<CR>
nnoremap ,x :let @j = '^\%(链接：\)\?["''()]*\([^'']\{-}\))\?[.,]\?$'<CR>:let @k = substitute(expand('<cWORD>'),@j,'\1','')<CR>:exec 'silent !'.shellescape(g:ff_browser,1).' '.shellescape(@k,1)<CR>:redraw!<CR>
" TODO: typical use cases: 1. man page, <url> 2. enclosed by parentheses, 3. enclosed by brackets.
" modular step, 1. selection of raw text, eg, <cWORD> in vim. 2. extract specific part 3. expand variable, eg, $HOME
" merge to gf, be functional, be conservative (security).
" -- below are failed cases.
" See [[https://github.com/emacs-helm/helm/wiki#helm-completion-vs-emacs-completion][Helm wiki]]

" https://vi.stackexchange.com/a/13756/10254
" This notation works (file name + trailing : + / pat /)
"
" /usr/include/stdio.h:/int printf/  -- `file name` + `:` + `/ pat /`
" /usr/include/stdio.h:+/int printf/
" /usr/include/stdio.h: /int printf/
" /usr/include/stdio.h: /#define\s/
" /usr/include/stdio.h: /^#define\sSEEK/
" ~/code/py/numpy/numpy/core/shape_base.py:/def vstack/
" with function and mapping below.
"
nn gf :<C-u>call Gf_search()<CR>
func! Gf_search() abort
" fixed: try pass below situation.
" src/raft/raft.go:118:// example code 
" readcsv.h:3:// #include " precompile.h"
" sol 1. step 1. (virtually) go start cWORD. 2. do the rest.
" sol 2. case 1 no space. 2 
    let word = expand('<cWORD>')
    let filename = substitute(word, '\(..\+\): \?\/\(.*\)\/[,.]*','\1', '')
    if filename != word     " no space
        let pat = substitute(word, '\(..\+\): \?\/\(.*\)\/[,.]*','\2', '')
        let pat = substitute(pat, '\\', '\\\\', 'g')
        if len(pat) >= 3
            sil exec 'e +/'.pat filename
            return
        endif
    endif
    let idx = stridx(word, ':')
    if idx != -1
        let remline = strpart(getline('.'),col('.'))
        let pat = substitute(remline, '.*[:+ ]/\([^/]\+\)/.*', '\1', "")
        if pat != remline
            " echo pat
            " return
            let pat = substitute(pat, '\\', '\\\\', 'g')
            let pat = substitute(pat, ' ', '\\ ', 'g')
            let filename = expand('<cfile>')
            sil exec 'e +/'.pat filename
            return
            " echo match('http://scikit-learn.org/stable/user_guide.html ',  'https\?://')
        elseif match(word, 'https\?://') != -1
            norm ,x
            " ExtractURLThenOpenInBrowser
            return
        endif
    endif
    " fallback to builtin gf
    norm! gF
endfunc

"gf, see " url
" nnoremap gf gF
" -- problem of gf to gF, delay, since timeoutlen=200

" nnoremap  :exec 'echo '.expand('<cWORD>')<CR>
nnoremap <Space>e :let @j = '['',()]*\([^''=, ]*\).*'<CR>:let @k = substitute(expand('<cWORD>'),@j,'\1','')<CR>:exec 'echo '@k<CR>
"nnoremap R :source $MYVIMRC<CR>

"kb(key binding), see " alt

" echom &cpo
set cpo-=C      " remove 'C' from cpo, since line-continuation is used here.
set cpo-=A      " remove 'A' from cpo, do not make file buffer #, when `:w file`.
let g:gdword = ""
func! WordPreprocessor() abort
    let g:gdword = expand('<cword>')
    if strlen(g:gdword) <= 4
        return
            " disappeared   -- remove two chars
              " succeed
    else    " remove last char
            " continued
            " zigzags overcorrects works
        if g:gdword =~ '^.*[^i]ed$'     
                 \ || g:gdword =~ '^.*[edgklnrt]s$'
            let g:gdword = g:gdword[:-2]
            " echo 'works' =~ '^.*[gklrt]s$'     
            " echo "[".g:gdword."]"
            " echo g:gdword[:-2]
        endif
        " interfering stopping
    endif
    echo g:gdword
endfunc

if g:my_current_platform > 1    " window or cygwin
nnoremap j :<C-u>call WordPreprocessor()<CR>:exec "!'D:/Program Files/GoldenDict/GoldenDict.exe' ".g:gdword."&"<CR>:redraw!<CR>
inoremap j <Esc>:<C-u>call WordPreprocessor()<CR>:exec "!'D:/Program Files/GoldenDict/GoldenDict.exe' ".g:gdword."&"<CR>:redraw!<CR><Right>
" exec "!'D:/Program Files/GoldenDict/GoldenDict.exe'" g:gdword "&"
" !'D:/Program Files/GoldenDict/GoldenDict.exe' g:gdword &
else
" nnoremap j :sil! !goldendict <cword>&<CR>:redraw!<CR>
nnoremap j :<C-u>call WordPreprocessor()<CR>:exec "!goldendict ".g:gdword."&"<CR><CR>
endif
"goldendict, see " alt(kb)
" TODO: add a preprocessor, eg, remove plural form, before call goldendict.

func! Echo_Option_Or_Expression()
    " TODO: combine current ^o and ^e, for echo option and expression evaluation.
    let word = expand('<cword>')
    try
        exec 'set '.word.'?'
    catch E518
        " echo 'E518'
        exec 'echo '.expand('<cWORD>')
        " g:ctrlp_custom_ignore
    endtry
endfunc
"echo
" nnoremap <Leader>o :exec 'verbose set '.expand('<cword>') '?'<CR>
nnoremap <Space>o :let @j = '['',]*\([^'',]*\).*'<CR>:let @k = substitute(expand('<cword>'),@j,'\1','')<CR>:exec 'set '@k'?'<CR>
nnoremap <Space>o :let @j = '['',]*\([^'',]*\).*'<CR>:let @k = substitute(expand('<cword>'),@j,'\1','')<CR>:exec 'set '@k'?'<CR>
nnoremap <Space>o :exec 'echo $'.expand('<cword>')<CR>
nnoremap <Space>o :exec 'echo '.expand('<cWORD>')<CR>
nnoremap <Space>o :<C-u>call Echo_Option_Or_Expression()<CR>
nnoremap <Space>w :pwd<CR>
nnoremap ;d :pwd<CR>
" nnoremap ]d :cd %:p:h \| pwd<CR>
" nnoremap ;s :echo expand('#:p')<CR>
nnoremap ;w :echo expand('<cWORD>')<CR>
nnoremap ;a ;

func! Man_cword()
    if &keywordprg == ':help'
        norm! K
        return
    endif
    let section = ""
    let word = expand('<cWORD>')
    let idx = match(word, '(\d[p]\?).\?$')  " pause(2) kill(1) getrusage(3p)
    " echo idx
    if idx > 0
        let section = strpart(word,idx+1,1)
        " echo section
        let word = strpart(word,0,idx)
        " let word = substitute(word, '(\(\d\)).\?$', '', '')
    else
        let word = expand('<cword>')  " fallback
    endif 
    exec '!man' section word
    " echo section word
endfunc

"man, see " help
autocmd FileType man set nonumber norelativenumber
" NOTE: make sure BASH_ENV is properly set, see " env.
func! Setup_plg()   " used by autocmd FileType plg call Setup_plg()
    " extension: accept arg to distinguish different cases.
    nnoremap <buffer> <Space>k :set iskeyword+=-<CR>:!man <cword> > ~/.tmprun<CR>:redraw!<CR>:set iskeyword-=-<CR>:tabe ~/.tmprun\|e<CR>
    " nnoremap <buffer> K :set iskeyword+=-<CR>:sil! !man <cword><CR>:redraw!<CR>:set iskeyword-=-<CR>
    nnoremap <buffer> K :call Man_cword()<CR>
    nnoremap <buffer> qk :set iskeyword+=- \| let g:hword_man = expand('<cword>') \| set iskeyword-=-<CR>:exec '!h' g:hword_man<CR>|" echo help
    nnoremap <buffer> mv :set iskeyword+=- \| let g:hword_man = expand('<cword>') \| set iskeyword-=-<CR>:exec '!v' g:hword_man<CR>|" echo help
    nnoremap <buffer> zj :set iskeyword+=- \| let g:hword_man = expand('<cword>') \| set iskeyword-=-<CR>:exec '!h' g:hword_man<CR>|" echo help
    nnoremap <buffer> zk :set iskeyword+=- \| let g:hword_man = expand('<cword>') \| set iskeyword-=-<CR>:sil! exec '!h' g:hword_man '> ~/.tmprun'<CR>:e ~/.tmprun\|e<CR>|" redirect help then edit
    nnoremap <buffer> ,s :set iskeyword+=- \| let g:hword_man = expand('<cword>') \| set iskeyword-=-<CR>:sil! exec '!show' g:hword_man '> ~/.tmprun'<CR>:e ~/.tmprun\|e<CR>|" redirect package info then edit
endfunc
augroup vim_man
    autocmd!
    " comment
    autocmd BufRead,BufNewFile *.{plg,scp,soc} set cms=#%s
    " K, <leader>k, to invoke man page
    " zj, zk, qk, to invoke help, ':!h command', function h() from ~/.bashrc
    autocmd BufRead,BufNewFile *.{plg,scp,soc},.{bashrc,bvimbrc} :call Setup_plg()
    " for bt=nofile, or scratch buffer
    " if v:version >= 704
    " autocmd OptionSet buftype if v:option_new == 'nofile' | call Setup_plg() | endif
    " endif
    " this VimEnter needed because previous OptionSet autocmd do not fire up when startup,
    " and the *nested* is needed to force it to fire up. for more see edit.plg " autocmd
    autocmd VimEnter * nested if &bt == 'nofile' | set bt=nofile|endif
    autocmd BufRead *.tmp{doc,help,run} nested set bt=nofile
    autocmd BufRead {unix,lx}.scp,{C,cplus}.scp setlocal path+=/usr/include/x86_64-linux-gnu/
    " TODO: ,s to show package info, eg, wrapper function of 'apt-cache show'.
augroup END

"info("version), see " echo " help
nnoremap Y y$
" nnoremap zm :marks<CR>
"nnoremap U :map<CR>
" invoked by 'K'.
"help, see " info " man
" nnoremap K :exec "!" &keywordprg expand("<cword>")<CR>:redraw!<CR>|" not work with " ':help'
" n  K            @<Plug>ScripteaseHelp
" 	Last set from ~/.vim/bundle/vim-scriptease/plugin/scriptease.vim

let g:help_hist = []
func! VimUpdateHelpHist(bufnr) abort
    let idx = index(g:help_hist, a:bufnr)
    if idx != -1 | call remove(g:help_hist, idx) | endif
    call add(g:help_hist, a:bufnr)
endfunc
func! VimGotoHelpHist(...) abort
    let pos = get(a:000,0,1)
    if pos > 0 && pos > len(g:help_hist) | let pos = 0 | endif
    let nr = get(g:help_hist, -pos)
    if nr
        let wnr = 0
        for w in getwininfo()
            if index(g:help_hist, w['bufnr']) != -1
                let wnr = w['winnr']
                break
            endif
        endfor
        if wnr | exec wnr . 'winc w' | endif
        exec nr . 'b'
    endif
endfunc
command! -nargs=? HH call VimGotoHelpHist(<args>)

augroup vim_lang
    autocmd!
    autocmd Filetype vim setl iskeyword+=:
    autocmd FileType vim nnoremap <buffer> <Space>k :<C-u>call Vim_help()<CR>
autocmd FileType vim setlocal keywordprg=:help
" note 'autocmd BufNewFile,BufRead *.mf set filetype=txt' work, whereas 'autocmd! BufNewFile,BufRead *.mf set filetype=txt' not.

    autocmd BufRead,BufNewFile {{edit,vim}.plg,vim.soc} nnoremap <silent> <buffer> K :set iskeyword+=- \| set iskeyword+=^ \| let g:hword_vim = expand('<cword>') \|
                \ set iskeyword-=- \| set iskeyword-=^<CR>:exec 'help ' g:hword_vim<CR>
    autocmd BufRead,BufNewFile {{edit,vim}.plg,vim.soc}
                \ nnoremap <buffer> <Space>k :<C-u>call Vim_help()<CR>
    " below same as first one of this autocmd group
    autocmd FileType help autocmd BufLeave <buffer> call VimUpdateHelpHist(bufnr('%'))
    autocmd FileType help set modifiable |
                \ nnoremap <silent> <buffer> K :set iskeyword+=- \| set iskeyword+=^ \| let g:hword_vim = expand('<cword>') \|
                \ set iskeyword-=- \| set iskeyword-=^<CR>:exec 'help ' g:hword_vim<CR>
                " \ set bt=nofile |
                " \ call LocalWindowStatusline() |
                " \ nnoremap \g :edit \| set ft=help<CR>
augroup END
" autocmd FileType help wincmd L
" autocmd FileType help exec ':$wincmd w'
" set keywordprg=pydoc
" set keywordprg=man
" set keywordprg=:help
nnoremap ,h :h<Space>
"use ahk to map <C-;> to hide current window
"    ^;::send :hide{Enter}
nnoremap <Leader>a :exec 'r!type '.shellescape(expand('<cword>'))<CR>
nnoremap <Space>' :scr<CR>

func! GetInput(hint)    " https://stackoverflow.com/a/15274117/3625404
    call inputsave()
    let cmd = input(a:hint)
    call inputrestore()
    return cmd
endfunc

func! CaptureShellCommand(cmd)
            call WinScratch('','',g:sz_scratch, exists('b:cpurge') ? b:cpurge : g:cpurge)
            exec 'r!'. a:cmd
            if g:st_winback
                winc p
            endif
            redraw!
endfunc

func! GetInputCommandThenCaptureAndPut()
    " cmdline keymap works, eg, <C-k> to get last input, <C-f> to open edit window, <C-r> insert register, ';' to cancel and exit.
    let cmd = GetInput('ex-command to execute: ')
    if cmd =~ '^\s*!'   " eg, '!ls', '!ll', redraw needed.
        exec 'r'.cmd
        redraw!
    elseif cmd =~ '^ [[.a-zA-z0-9].*'    " one space before shell command, add '!', then run and read.
        if cmd == ' ns'
            term ++curwin nvidia-smi
        else
            " exec 'r!' cmd
            call CaptureShellCommand(cmd)
        endif
    elseif cmd =~ '^	[[.a-zA-z0-9].*'  " leading '<Tab>' key, execute shell command, witout capture.
        exec '!' cmd
    else
        if strlen(cmd) == 1     " customized shortcut
            if cmd == 's'
                let cmd = 'scr'
            elseif cmd == 'k' || cmd == 'm'   " :k is alias of :mark
                let cmd = 'marks'
            endif
        elseif cmd =~ '^\s*''\(\w*\)''\?\s*$'   " option start with single quote, closing one optional.
            let cmd = 'set '. substitute(cmd, '^\s*''\(\w*\)''\?\s*$', '\1', '').'?'
            " let cmd = 'set '.cmd.'?'
        endif
        let command = matchstr(cmd, '\w\+')
        if strlen(command) == 0
        elseif exists(':'.command)
            " breaks for '%!uniq'
            " if strgetchar(cmd,1) == 37  " first char is '%'
            "     call PutAfterCapture('\'.cmd)
            " else
                call PutAfterCapture(cmd)
            " endif
        else    " not ex command, try run and read shell command.
            call CaptureShellCommand(cmd)
        endif
    endif
endfunc

    " echom expand('<sfile>:t').expand('<slnum>')
"src, "proj, "cv, "reid
" let torch_qreid = (stridx($PWD, 'torch') >= 0) * 2 + (stridx($PWD, 'qreid/') >= 0)
" use `set noswapfile` on sever
if stridx($PWD, 'torch') >= 0 || stridx($PWD, 'qreid/') >= 0
let &path = $HOME.'/cv/src/torch'.&path
exec 'augroup '.expand('<sfile>:t').expand('<slnum>')
    au!
    autocmd Filetype python exec 'setl tags+='.$HOME.'/cv/src/torch/tags'
augroup END
endif

func! VimLMatchItem()
    let word = expand('<cword>')
    if word == 'if'
        call search('\%(^\|\s\)\@1<=endif\>')
    elseif word == 'endif'
        call search('\%(^\|^\s\)\@1<=if\>','b')
    elseif word == 'func'
        call search('\%(^\|\s\)\@1<=endfunc\>')
    elseif word == 'endfunc'
        call search('\%(^\|\s\)\@1<=func\>','b')
    elseif word == 'augroup'
        if stridx(getline('.'), 'augroup END') >= 0
            call search('\%(^\|\s\|\%(exec '."'".'\)\)\@<=augroup\%( END\)\@!','b')
        else
            call search('\%(^\|\s\)\@1<=augroup')
        endif
    else
        norm! %
    endif
endfunc
exec 'augroup '.expand('<sfile>:t').expand('<slnum>')
    au!
    autocmd Filetype vim nnoremap <buffer> % :<C-u>call VimLMatchItem()<CR>
augroup END


" Capture PutAfterCapture
" eg, marks,aa
" eg, <M-x> then nn K to debug mapping of K.
"capture
"TODO: improve Capture function, 1. handle both ex command and external shell command.
"2. do not clutter cmdline history, using expression register instead.
nnoremap ,c :<C-u>call GetInputCommandThenCaptureAndPut()<CR>
nnoremap x :<C-u>call GetInputCommandThenCaptureAndPut()<CR>
inoremap x <Esc>:<C-u>call GetInputCommandThenCaptureAndPut()<CR>
nnoremap \r :let @k=getline('.')<CR>:exec "call PutAfterCapture(@k)"<CR>
nnoremap \r :source $MYVIMRC<CR>

func! Old_Vim_help()
" :let @j = '\\\?"\?\(:\[range\]\)\?[''\|\*(,]*\([^''\|\*()[=,]*(\?\).*'<CR>:let @k = substitute(expand('<cWORD>'),@j,'\2','')<CR>:exec 'help' @k<CR>
    let word = expand('<cWORD>')
    " echo word
    if strlen(word) < 3 || word =~ "'\\w\\+'"   " second match, single quoted \w\+ for option
    elseif word =~ '^\w\+('     " function call, matchstr()
        " echo "function"
        let word = matchstr(word, '^\w\+(')
    elseif word =~  '^\(\w\+\)[+-.^]\?=.*'     " option set, set path+=/usr/local/X11
        let word = substitute(word, '^\(\w\+\)[+-.^]\?=.*', '\1', '')
        " echo match('path+=/usr/local/X11', '^\(\w\+\)[+-.^]\?=.*')
    elseif word =~ '^["'']\([^"'']\+\)["''][:.?,]$'       " quoted string, with optional trailing punctuation.
        " echo 'quoted string'
        let word = substitute(word, '^["'']\([^"'']\+\)["''][:.?,]$','\1','')
    elseif word =~ '^[bwtglsv]:'    " internal-variable
    else
        " let pat = '\\\?"\?\(:\[range\]\)\?[''\|\*(,]*\([^''\|\*()[=,]*(\?\).*'
        " let word = substitute(word, pat, '\2', '')
        " echo "[".word."]"
        let word = substitute(word, '\(.\{-}\)[:.,''`]\+','\1','')
        " submatch
        " echo word =~ '\(.\{-}\)[:.,''`]*'
    endif
    " echo "[".word."]"
    exec 'help ' word
endfunc
" test cases
" a:000 E35: "\m"
" error code at least 2 digits.

func! Vim_help()    " utilize exists()
    let isk=&isk
    set isk+=-
    let w = expand('<cword>')
    let ww = substitute(expand('<cWORD>'), '[,.?]$','','')
    if ww[0] == '*' && ww[-1:] == '*'
        let word = ww[1:-2]
    elseif strlen(ww) <= 3 || ww =~ "'\\w\\+'"   " option: single quoted \w\+
        let word = ww   " a:0 'cp'
    elseif ww[0] == ':' && match(ww,':',1) == -1
        let word = matchstr(ww,'\w\+',1)
    elseif ww =~ '^\w\+('     " function call
        let word = matchstr(ww, '^\w\+(')
    elseif ww =~ '\d\d\?\.\d\d\?'
        let word = ww
    else
" <q-args> bitwise-function
        let word = w
    endif
    let &isk=isk
    exec 'help ' word
endfunc

" refto http://www.fantxi.com/blog/archives/vim-view-in-browser-func/
"D:/Program Files/Mozilla Firefox/Firefox.exe",
"+ 在浏览器预览 for win32
function! ViewInBrowser(name)
    let file = expand("%:p")
    exec ":update " . file
    let l:browsers = {
                \"cr":"D:/WebDevelopment/Browser/Chrome/Chrome.exe",
                \"ff":fnameescape("d:\Program Files\Mozilla Firefox\firefox.exe"),
                \" op":"D:/WebDevelopment/Browser/Opera/opera.exe",
                \"ie":"C:/progra~1/intern~1/iexplore.exe",
                \"ie6":"D:/WebDevelopment/Browser/IETester/IETester.exe -ie6",
                \"ie9":"D:/WebDevelopment/Browser/IETester/IETester.exe -ie9",
                \"iea":"D:/WebDevelopment/Browser/IETester/IETester.exe -all"
                \}
    exec ":silent !start ". l:browsers[a:name] file
endfunction
"nmap <f3> :call ViewInBrowser("ff")<cr>
"nmap <f4>cr :call ViewInBrowser("cr")<cr>
"nmap <f4>ff :call ViewInBrowser("ff")<cr>

func! s:FixCtrlPBuffer()
    " echom winnr() winnr('#')
    if winnr() > 1
        let wnr = winnr('#')
        let nr = winbufnr(wnr)
        " if nr != bufnr('%') && getbufinfo(nr).hidden
        " echom getbufinfo(nr)[0].hidden
        if getbufvar(nr,'&bt') == 'nofile'
        " echo wnr nr bufnr('%') 
            " echo bufnr('%') winbufnr('.')
            " echo getbufinfo(winbufnr(winnr('#')))
            " echo getbufinfo(1)
            " echo getbufvar(1,'&ft') 'bt' getbufvar(1,'&bt')
            " echo getbufvar(78,'&ft') 'bt' getbufvar(78,'&bt')
            exec wnr . 'close'
        endif
    endif
endfunc


"fzf, see " ctrlp(which could be too slow)
" set rtp+=~/.vim/bundle/fzf/

"denite, see "" ctrlp
if isdirectory($HOME.'/.vim/bundle/denite.nvim')
" disable highlight https://github.com/Shougo/denite.nvim/issues/97
call denite#custom#option('_', 'highlight_mode_insert', 'CursorLine')
call denite#custom#option('_', 'highlight_matched_range', 'None')
call denite#custom#option('_', 'highlight_matched_char', 'None')
call denite#custom#map('insert', '<C-h>',
      \ '<denite:smart_delete_char_before_caret>', 'noremap')
" from https://github.com/Shougo/denite.nvim/issues/498
nnoremap <space>i :<C-u>Denite buffer<CR>
nnoremap <space>p :<C-u>DeniteBufferDir file/rec<CR>
" just listing buffers in current directory? https://github.com/Shougo/denite.nvim/issues/486
" kind? https://github.com/Shougo/denite.nvim/issues/428
endif

"leaderf, see "" ctrlp
if isdirectory($HOME.'/.vim/bundle/LeaderF')
nnoremap <space>i :<C-u>LeaderfBuffer<CR>
nnoremap <space>p :<C-u>LeaderfFile<CR>
let g:Lf_ShowHidden=1
endif

"grep, see " ack
call CmdAlias('grep',' Grep')
call CmdAlias('vim',' Vimgrep')
call CmdAlias('vi',' Vimgrep')
call CmdAlias('cop',' copen')

let g:copen = 1

func! QfRunSilent(cmd,...)
    let shellpipe=&shellpipe
    let &shellpipe='2>&1 >'
    let cmd_post = get(a:,0,'')
    try
        exec a:cmd
        catch /\<E\d\+/|" E480
        finally
        let &shellpipe=shellpipe
    endtry
    let n = len(getqflist())
    echo n 'match'
    if n && (get(b:,'copen',0) || g:copen)
        copen
    endif
endfunc

func! Grep(args)
    call QfRunSilent( 'sil grep! ' . shellescape(a:args,1) )
    " call QfRunSilent( 'sil grep! ' . a:args . '<bar> redraw!' )
    redraw!
endfunc

func! GrepCurrFile(pat)
    call QfRunSilent( 'vimgrep /' . a:pat .'/j ' . expand('%') )
    " exec 'sil! vimgrep /' . a:pat .'/j ' . expand('%')
endfunc

command! -nargs=? Vimgrep call GrepCurrFile(<q-args>)
command! -nargs=? Grep call Grep(<q-args>)

if executable('rg')
    let g:ackprg = 'rg -i --hidden -n --column'
    let &grepprg=g:ackprg
elseif executable('ag')
    " will g:ackprg conflict with 'grepprg', which will take precedence?
    " let g:ackprg = 'ag --vimgrep'     " --vimgrep will print every match on the same line.
    let g:ackprg = 'ag --nogroup --nocolor --column'
" Note we extract the column as well as the file and line number     set grepprg=ag\ --nogroup\ --nocolor\ --column     set grepformat=%f:%l:%c%m
    " will --nocolor make it even faster, is it worth to comprise readability?
    " below https://robots.thoughtbot.com/faster-grepping-in-vim 
    " Use ag over grep
    let &grepprg=g:ackprg
endif
"ak ("ack), "ag, see " grep " quickfix, since quickfix or location-list is used.
" sil grep! fzf|cope|redraw!
nnoremap qf :Ack! expand("<cword>")<CR>
nnoremap qf :exec 'Ack! "\b'.expand("<cword>").'\b"'<CR>
" autocmd FileType ruby nnoremap <buffer> K :<C-u>execute 'Ack! "\bdef '. expand('<cword>'). '\b"'<CR>
call CmdAlias('Ack',' Ack!')
    " nnoremap <space>j :<C-u>execute 'Ack! "\b'. expand('<cword>'). '\b"'<CR>
    " nnoremap <space>j :<C-u> exec 'sil! gr!'.expand('<cword>')\|cope\|redraw!<CR>
" search line begin, when search across file, is faster thus results less lag, if you need
" in line search, just delete anchor '^' and do the search.
nnoremap ;f :Ack! ^\"
"repo, "git, see also " grep
" TODO adapt below to git repo only, for search tags in source files.
" -- also, add a key to `git add current file in git repo`.
if getcwd() =~ "/code/qeatzy/"
    nnoremap ;f :Ack! ^\/\/\ *\"
    nnoremap ,a :!cd %:p:h && git add %<CR>
    nnoremap ,, :s/,//gn<CR>   |" count semicolon
    nnoremap <space>n :s/,//gn<CR>
else
    nnoremap <space>, :s/,//gn<CR>
    MapToggle ,a autoindent
endif
if getcwd() =~ "/code/qeatzy/..System"
    nnoremap ;f :Ack! ""<Left>
    cnorea cl class
    cnorea us using
endif

func! Ag_search(args,...)
    " args:string, jump:bool, copen:bool, hi:bitwise-bool:hidden+ignorecase
    " args == 'options'.'pattern', options could be empty
    let args = escape(!empty(a:args) ? a:args : expand('<cword>'), '[]|%#()')
    let jump = get(a:, 1, 0)
    let copen = get(a:, 2, 0)
    let hi = get(a:, 3, 3)
    let fn_redir = '~/.tmprun'
    echo 'ag '.args.' >'.fn_redir  '|' jump copen hi
    " call system('ag '.args.' >'.fn_redir)
    " exec (jump ? 'cfile ' : 'cgetf ').fn_redir
    let cmd = 'ag --nocolor --nogroup '.(hi%2 ? '-i ' : '').(and(hi,2)?'--hidden ' : '')
    let result = system(cmd.args)
    " echo result
    let save_errorformat = &l:errorformat
    " let &l:errorformat = '%f:%l' " '%f:%l:%c:%m,%f:%l:%m'  
    " let &l:errorformat = '%f:%l:%c:%m,%f:%l:%m'  
    let &l:errorformat = '%f:%l:%m'  
    try
        " bug? if result only one file, cex works, cgete fails.
        " similar case for (cfile cgetf) and (cbuf cgetb)
        if jump
            cex result
        else
            cgete result
        endif
    finally
        let &l:errorformat = save_errorformat
    endtry
    if copen
        botright copen
    endif
endfunc
" call Ag_search('^.dist')
command! -nargs=* -range A call Ag_search(<q-args>,1) " bug? when 1-line result, cex works, cgete fails
command! -nargs=* -range A call Ag_search(<q-args>,0,1)
command! -nargs=* -range AJ call Ag_search("-G [^-]ja[^npvc] ".<q-args>,0,1)

" func! QfGotoPos(forward, count_) abort
func! QfGotoPos(forward, count_)
    let l:count = a:count_ == 0 ? '' : a:count_
    if count == 1
        exec count . (len(filter(getqflist(), 'v:val.valid == 1')) ? 'cc' : 'll')
    else
        try
        exec count . (len(filter(getqflist(), 'v:val.valid == 1')) ? 'c' : 'l') . (a:forward ? 'next' : 'prev')
        catch /\<E\d\+/|" E553 E776, add cc to handle only one item case
            sil! cc
        endtry
    endif
endfunc

"qf(quickfix), see " ack
nnoremap <C-n> :<C-u>call QfGotoPos(1,v:count)<CR>
nnoremap <C-p> :<C-u>call QfGotoPos(0,v:count)<CR>
" use <C-p> <C-n> :cn :cp for quickfix or :lne :lp for location-list . or type ';l<someletter>' quickly?
" nnoremap <C-n> :try \| cn \| catch \| lne \| endtry<CR>
" nnoremap <C-p> :try \| cp \| catch \| lp \| endtry<CR>

"cs(code search), see " code

"tag, see " cs
set tags+=../tags
if v:version >= 800
set tagcase=smart
endif
"cscope, see " tag
if v:version >= 800
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-
endif

" fdm fmr 
" zm zr (more/reduce level)
"fold, see " code
set foldmethod=manual
set foldlevel=99

" verb set include " the default value works C and C++, scriptease.vim setting is good for vim file.
"code, see "" ls " git " cms " cs(code search) " lang
nnoremap [3 [#
nnoremap ]3 ]#

" change ':setl bt=nofile', that is, do some preventing checking. eg, set only if buffer has no file associated with.
" or if you advertently turn an modified buffer to nofile, you can use ':file fname' command to
" set it back.
"trap, see 
nnoremap qn :setl bt=nofile<CR>
nnoremap ,q :setl bt=<CR>

"view, 
" cursor go next match and make it at the top of screen.
nnoremap <F12> nzt
nnoremap <S-F12> Nzt
":an extra view mode for docs: eg, manual, books in txt format, etc.
" toask: vim internal variable for count of lines in one screen
func! TogViewMode()
    " feature: add word indicating status in status bar, eg, 'view mode: on'.
    " if !exists('b:is_view_mode')
    "     let b:is_view_mode = 0
    " endif
    " if b:is_view_mode
    if !empty(maparg('j','n'))
        " echo maparg('j','n')
        try
        nunmap <buffer> <space>
        nunmap <buffer> <S-space>
        nunmap <buffer> j
        nunmap <buffer> k
        nunmap <buffer> d
        nunmap <buffer> s
        catch /^E31/
        endtry
    else
        nnoremap <buffer> <space> :call MyPageDown(1)<CR>
        " shift space may not work on some terminal, those who can't distinguish shift space from space.
        nnoremap <buffer> <S-space> :call MyPageUp(1)<CR>
        nnoremap <buffer> j :call MyPageDown(1)<CR>
        nnoremap <buffer> k :call MyPageUp(1)<CR>
        nnoremap <buffer> d :call MyPageDown(1)<CR>
        nnoremap <buffer> s :call MyPageUp(1)<CR>
    endif
    " let b:is_view_mode = (b:is_view_mode + 1) % 2
endfunc
nnoremap ;v :call TogViewMode()<CR>
" NOTE: toggle wrap for line motion command j k 0, in both normal and visual mode.
let s:is_line_wrap_for_jk0 = 0
func! TogLineWrapForjk0()
    if s:is_line_wrap_for_jk0
        xunmap <buffer> j|xunmap <buffer> k|xunmap <buffer> 0
        nunmap <buffer> j|nunmap <buffer> k|nunmap <buffer> 0
        echom 'no wrap for line motion command j k 0, the default behavior.'
    else
        xnoremap <buffer> j gj|xnoremap <buffer> k gk|xnoremap <buffer> 0 g0
        nnoremap <buffer> j gj|nnoremap <buffer> k gk|nnoremap <buffer> 0 g0
        echom 'wrap for line motion command j k 0.'
    endif
    let s:is_line_wrap_for_jk0 = (s:is_line_wrap_for_jk0 + 1) % 2
endfunc
nnoremap <F5> :call TogLineWrapForjk0()<CR>

" run command
"nnoremap <F9> :!./%<CR>
"nnoremap <F9> :w !node<CR>
"inoremap <F9> <Esc>:w !node<CR>
"search, "list, "cycle, see " case " highlight
func! OptToggle(opt)
    exec 'set ' . a:opt . '!'
    return "j\<C-h>"
endfunc
" cnoremap <expr> <F1> (getcmdtype() =~# '[/\?]')? OptToggle('hlsearch') : '<F1>'

"highlight, see " search " color
" highlight word under cursor.
" highlight flicker cterm=bold ctermfg=white
" au CursorMoved <buffer> exe 'match flicker /\V\<'.escape(expand('<cword>'), '/').'\>/'



"substitute, 
"pdf
" change comma
" s/\v‘ *([^‘’ ]+) *’/'\1'/g

" :di[splay] is same as :reg[ister]
" use ':di<CR>' to echo register contents.
" nnoremap ,, :reg<CR>  -- :di[splay] is same as :reg[ister]
"macro, "register
" }J useful to delete empty line separated line blocks, eg, "33@@"
let @b=':s/ /_/g'
let @w='}J'
" let @r=':quick-temp-command-here'   " r for Run vimscript command.
" let @q=':let @*=@"\'
let @p =':let g:my_doc_program="perldoc "'
let @q ='A a0+'
let @f =':let g:my_doc_program="perldoc -f "'
let @v =':let g:my_doc_program="perldoc -v "'
let @n =':let g:my_doc_program=" cppman "'
let @m =':let g:my_doc_program=" man "'
let @s =':let g:my_doc_program=" man std::"'
let @c =':let g:my_doc_program=" cppman "'
let @i =':let g:my_doc_program=" info "'
let @j =':let g:my_doc_program=" javadoc "'
let @k=':nunmap K'

"page, see " screen
set nostartofline
func! MyPageDown(cnt) range
    " Borland behaviour = the cursor keeps the same xy position during pageup/down.
    " for more, see edit.plg:/"page and " window
    " accept count, similar to ^f
    " principle, ^d ^u in normal mode is of Borland behaviour.
    " TODO: 1. handle long wrapped lines, 2. set jumplist manually
    let l:old_winline = winline()
    " let l:old_pos=getcurpos()[1:]
    " echom l:old_pos
    " let l:old_pos[0]+=(a:cnt * (winheight('%') - 1))
    " call cursor(l:old_pos)
    let l:old_pos=getcurpos()
    let l:old_pos[1]+=(a:cnt * (winheight('%') - 1))
    call setpos('.',l:old_pos)
    let l:new_winline = winline()
    if l:old_winline < l:new_winline
        exec 'norm! '.(l:new_winline - l:old_winline).''
    elseif l:old_winline > l:new_winline
        exec 'norm! '.(l:old_winline - l:new_winline).''
    endif
endfunc
func! MyPageUp(cnt) range
    " see MyPageDown()
    let l:old_winline = winline()
    let l:old_pos=getcurpos()
    let l:old_pos[1]-=(a:cnt * (winheight('%') - 1))
    call setpos('.',l:old_pos)
    let l:new_winline = winline()
    if l:old_winline < l:new_winline
        exec 'norm! '.(l:new_winline - l:old_winline).''
    elseif l:old_winline > l:new_winline
        exec 'norm! '.(l:old_winline - l:new_winline).''
    endif
endfunc
" below key bindings for PageDown/PageUp no longer used, instead, TogViewMode() is used.
" nnoremap <C-b> :call MyPageUp(v:count1)<CR>

set virtualedit=    |"-- for block selection, press $ at the last. https://vi.stackexchange.com/questions/4363/visual-block-some-right-end-selections-seem-impossible/4365#4365
"scroll(screen), see " page
nnoremap n <C-f>
nnoremap b <C-b>
nnoremap k zz
nnoremap j zz
nnoremap h zt
nnoremap l zb
nnoremap zh zt
set scrolloff=1     " If set to a very large value (999) the cursor line will always be in the middle of the window.
"screen, "display, TODO to merge setup in other place to here.
set scrolloff=0

""motion, see " line " scroll
" gm to go line middle
nnoremap <BS> k$
"sneak
if isdirectory(expand("~/.vim/bundle/vim-sneak"))
let g:sneak#label = 1
endif

" whichwrap
set nowrap
" set showbreak=+ |" to show a + to indicate that Vim is doing wrapping.  https://vi.stackexchange.com/a/90/10254
"long-lines, see "" line
" motion: g$ g0 | gj g3j 4gj | virtualedit may or may not be your need.

"line, see " lw(line wrap) " word " g,
"   " long-lines
nnoremap <silent> <space>d :t.<CR>
" nnoremap <C-j> gJ|" Don't insert or remove any spaces.
command! -bar -range=% Reverse <line1>,<line2>global/^/m<line1>-1 |" reverse line

" similar to expand('<cWORD>') but trim punctuation.

func! CWORD()
    let word = expand('<cWORD>')
    let word = substitute(word,'[.,]\+$',"","")
    let word = substitute(word,'\(\[\|\]\)','\\\1',"g")
    return word
endfunc

" echo CWORD() " [153], ls, "|nn * /<C-r>=CWORD()<CR><CR>
"word, see " line
nnoremap <expr> g* search('<cWORD>')
set isfname-==  " '=' is not part of filename in most cases.

"lw(line wrap), see " line
" zl zL

" highlight
" line number, could change corlor used for highlight line number, 
"+ :highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
set number
set relativenumber 
nnoremap \n :set number! relativenumber!<CR>

"write, see "" edit
inorea ;s <Space>●|"s for seperator.

"correction, "spell, see " abbrev
inorea alos also
inorea contrl control
inorea dont don't
inorea filed field
inorea taht that

"latex
augroup tex_lang
    au!
    autocmd Filetype tex nnoremap <space>r :<C-u>!pdflatex %:r<CR>
    autocmd Filetype plaintex nnoremap <space>r :<C-u>!pdftex %:r<CR>
augroup END " tex_lang

"mf(multi-file), see "" edit
" save in quickfix window reflect to files associated. https://github.com/stefandtw/quickfix-reflector.vim

""editing/insert related key maps, see " mf(multi-file)
"   " write " spell " correction
" nnoremap K mp:-1join<CR>`p
"abbrev, " see " correction " spell
inorea <buffer> cr CR
inorea npt nullptr
inorea ifdb if (DEBUG)
inorea classs class {public:private:};3kf 
inorea nstest namespace test {void() {}}2kf(
inorea templateit template <typename Iterator, typename T = typename std::iterator_traits<Iterator>::value_type>
inorea templatefit template <typename ForwardIt, typename T = typename std::iterator_traits<ForwardIt>::value_type>
inorea templatebit template <typename BidirectIt, typename T = typename std::iterator_traits<BidirectIt>::value_type>
inorea templaterit template <typename RandomIt, typename T = typename std::iterator_traits<RandomIt>::value_type>
inorea templatect template < template<typename ... > class Container, typename T>
inorea templatecc template < template<typename ... > class Container, template<typename ... > class T_Cont, typename T, typename Iterator> // cc -- Container of Container.  use 'Container<T_Cont<T>> c'.
inorea templatecci template < template<typename ... > class Container, typename T_Cont, typename Iterator, typename T = typename std::iterator_traits<Iterator>::value_type> // cci -- Container of Container, i -- valut_type of T_Cont is implicit instead of deduced.  use 'Container<T_Cont> c'.
inorea repl REPL
inorea rakefile Rakefile
inorea makefile Makefile
inorea ide IDE
inorea readme README
inorea toread TOREAD
inorea todo TODO
inorea pgdn PgDn
inorea pgup PgUp
"spell
inorea vmp vimperator
inorea envv environment variable
cabbrev envv environment variable
inorea specch special character
inorea reff reference
cabbrev i^ inoremap <C-
cabbrev n^ nnoremap <C-
"yank
" nnoremap yg :<C-u>let @+=expand('%:p')<CR>
" yank last visual selection linewise.
nnoremap gy mp'<y'>`p
" yank word
" nnoremap yg mpByE`p
" nnoremap yg yibyi"yi)
nnoremap yiw mpyiw`p
nnoremap yaw mpyaw`p
nnoremap yv mp^yg_`p
"insert, see " digraph " imotion
nnoremap aa A
nnoremap ii I
" below from vim-rsi  https://github.com/tpope/vim-rsi
inoremap <C-A> <C-O>^
"digraph, see " insert
inoremap jf <C-q>u2022 |" insert bullet (•) and <space>. :set timeoutlen=200   for less delay
" ? undolevels  updatecount

"jump, see " ls " mark

func! Undo(pos)
    undo
    call setpos('.', a:pos)
endfunc

"undo, see " jump
" nnoremap <silent> u :ky<CR>:undo<CR>g`y:delmarks y<CR>
" nnoremap <silent> <C-r> :ky<CR>:redo<CR>g`y:delmarks y<CR>
" above two mapping same effect as below two, and below simpler.
" nnoremap u u``
" nnoremap u :call Undo(getcurpos())<CR>
" nnoremap <C-r> ``
inoremap <C-u> <C-g>u<C-u>
"inoremap <C-w> <C-g>u<C-w>

func! PasteAppendWithSpace()
    if matchstr(getline('.'), '\%' . col('.') . 'c.') != ' ' |" last char of current line, from https://stackoverflow.com/a/23323958/3625404
        norm! A 
    endif
    norm! $p
endfunc

" yank-append to line end.
" yesterday I learned about the ]p command. This pastes the contents of a buffer just like p does, but it automatically adjusts the indent to match the line the cursor is on! This is excellent for moving code around.
"paste, "put, " clipboard
nnoremap zp :pu<CR>
nnoremap gpp :<C-u>call PasteAppendWithSpace()<CR>
" nnoremap gpp $p
" nnoremap zpp :pu*<CR>
" paste (possibly multiline and join them), substitute extra spaces, 
"+ and trim leading and trailing whitespaces.
"&future work, how to temporarily disable edit/delete/insert history in an atomic operation?
"nnoremap gp o<CR><Esc>mlkmpgp:'p,'lj<CR>:'ps/\s\+/ /g<CR>^"pd0g_a <Esc>"pD:se nohlsearch<CR>
nnoremap gp o<CR><Esc>mlkmp"+gp:'p,'lj<CR>:'ps/\s\+/ /g<CR>^"pd0g_a <Esc>"pD:s/ ;/;/g<CR>:s/ ,/,/g<CR>:s/‐ //g<CR>:s/ \./\./g<CR>:se nohlsearch<CR>
func! PasteAndJoinPossiblyReplace(reg)
    mark l
    exec 'pu ' . a:reg
    mark p
    'l+1,'pjoin!
    exec 'normal 0d^'
endfunc
nnoremap ,p :call PasteAndJoinPossiblyReplace('+')<CR>

func! Pdf_PasteAndJoinPossiblyReplace(reg)
    mark l
    exec 'pu ' . a:reg
    mark p
    'l+1,'pjoin
    " s/\v‘ *([^‘’]*[^‘’ ]+) *’/'\1'/g
    " s/\v[“‘] *([^“”‘’]*[^“”‘’ ]+) *[”’]/'\1'/g
    s/（/ (/g
    call histdel('search', -1)
    s/）/) /g
    call histdel('search', -1)
    s/\v  +/ /g
    call histdel('search', -1)
    s/∗/*/g
    call histdel('search', -1)
    " The, sicp.bks
    s/\v[]/Th/g
    s/\v[]/tt/g
    s/\v[]/ft/g
    " .!tr -C '' 'AM'
    call histdel('search', -1)
    call histdel('search', -1)
    call histdel('search', -1)
    s/\v[“] ?([^“”]*[^“” ]+) ?[”]/'\1'/g
    call histdel('search', -1)
    " s/\v[‘] ?([^‘’]*[^‘’ ]+) ?[’]/'\1'/g
    s/\v[‘]+ ?([^‘’]*[^‘’ ]+) ?[’]+/'\1'/g
    call histdel('search', -1)
    s/\v(⟨) ?([^⟨⟩]*[^⟨⟩ ]+) ?(⟩)/\1\2\3/g
    call histdel('search', -1)
    s/\v’\\0’/'\\0'/g
    call histdel('search', -1)
    s/\v(\w) ?’(([mstd]|ll|ve|re)[, .])/\1'\2/g
    call histdel('search', -1)
    s/[‐–−]/-/g
    call histdel('search', -1)
    s/\v([a-z])[-] /\1/gI
    call histdel('search', -1)
    s/\v([A-Z])[-] /\1-/gI
    call histdel('search', -1)
    s/\v (-[a-zA-Z]{3,}\>)/\1/g
    call histdel('search', -1)
    s/\v((\w\=)|(\[)|\() /\1/g
    call histdel('search', -1)
    s/\v (([=][[:alpha:]_])|(\]|\)|(\.$)))/\1/g
    call histdel('search', -1)
    " normal '^d0'
    s/\v(^\s+)|(\s+$)//
    call histdel('search', -1)
    s/\v ([.,:;]) /\1 /g
    call histdel('search', -1)
endfunc

"system-dependent setting for working directory
"platform
" or change to use dictionary or a class (similar to js prototype-based approach). eg,
" Mycolorscheme['0'] = 'default', ['cygwin'] = 'molokai'?
"if system('uname')[0:4] == 'Linux'
"    set cdpath+=
" instead of test uname, set global variables in ~/.vimrc, and test here.
if g:my_current_platform == 3   " cygwin
    nnoremap <silent> gp :silent! exec 'call '.Pdf_PasteAndJoinPossiblyReplace('*')<CR>
elseif g:my_current_platform == 2       " windows
    nnoremap <silent> gp :silent! exec 'call '.Pdf_PasteAndJoinPossiblyReplace('*')<CR>
else    " odd number for linux
    nnoremap <silent> gp :silent! exec 'call '.Pdf_PasteAndJoinPossiblyReplace('+')<CR>
endif 

""netrw, use dirvish instead
autocmd Filetype netrw setl bufhidden=wipe
" https://github.com/tpope/vim-vinegar/issues/13
" let g:netrw_banner=1
" let g:netrw_altfile=1   " though not solve the problem as the issue title stated. https://github.com/tpope/vim-vinegar/issues/74#issuecomment-272835909
let g:netrw_dirhistmax=50
" au NetrwMessage
autocmd BufWinEnter NetrwMessage nnoremap <buffer> <silent> q :<C-u> call Hide_cur_window_or_quit_vim(0)<CR>
" autocmd OptionSet NetrwMessage nnoremap <buffer> <silent> q :<C-u> call Hide_cur_window_or_quit_vim(0)<CR>
"     autocmd OptionSet buftype if v:option_new == 'nofile' | call Setup_plg() | endif
" autocmd BufWinEnter
" autocmd! BufWinEnter NetrwMessage

"smotion(search), see " motion
" center on the line been found
" nnoremap N Nzz
" nnoremap n nzz

func! GoParagraphStart(flags) range abort
    call cursor('.',1)
    if v:count < 2
        call search('\(\_^\s*\_$\n\_^.\)',a:flags)
    else
        let cnt = 0
        while cnt < v:count
            call search('\(\_^\s*\_$\n\_^.\)',a:flags) 
            let cnt += 1
        endwhile
    endif
endfunc

function! CreateNonPyMapping(extension)
    if a:extension !=? 'py'
        nnoremap <buffer> <silent> [ :call GoParagraphStart('be')<CR>|"--? should we set mark '?
        nnoremap <buffer> <silent> ] :call GoParagraphStart('e')<CR>
    endif
endfunction

augroup NonPyMapping
  autocmd!
  autocmd BufRead,BufNewFile * call CreateNonPyMapping(expand('<afile>:e'))
augroup END
" augroup PyChangeTimeout
"     autocmd!
"     autocmd BufEnter,BufLeave *.py set timeout!
" augroup END
MapToggle \t timeout
"motion, see " imotion " smotion
"*, '"*' for specification/commenting/better organiztion/similar to ctags, '""' to begin a topic, '"' to begin a subtopic, then you can seach topic and both subtopic with '/"topic', much consistent
inoremap <C-j> <Down>
inoremap <C-l> <C-o>A
inoremap <C-e> <C-o>A
inoremap <C-v> <C-r>+
inoremap gj <Esc>l
inoremap gjn <Esc>l:update<CR>
inoremap kj <Esc>l
inoremap jk <Esc>
inoremap jj <Esc>
"search, use <F9> <F10> to search two word (as header in docs, jump between notes/doc file).
""two search at once
cnoremap jj /;
cnoremap jj ^[\|[:space:]]\{4\}\w*(.*)$<Left><Left><Left><Left><Left><Left><Left><Left>
cnoremap jj /;/^
cnoremap kk ?;
cnoremap jk ;
inoremap kk <Esc>
nnoremap oo o<CR>

"imotion, see " motion
" <Down> work in wrapped line
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
" Insert newline without entering insert mode
" nnoremap <S-Enter> o<Esc>j
" nnoremap <M-Enter> o<Esc>j
nmap <S-Enter> O<Esc>

"" block operation
" append/prepend a line, then repeat linewise
vnoremap . :normal .<CR>
"+ or most usefully, write command to a regester, say register a, then gv to
" previous selected visual block, :'<,'>normal @a to repeat linewise. 
" copy inner via ci {^cf_"$r"} to regester a, then repeat on below lines.
" {^i"
"public string m_asdf;
    "public String m_lkhj;
        "public int m_hjkhjkh;
" a possible improvement is to shift named register for reusability
" vnoremap ~ :normal @q<CR>

"nlg, see "" ls
"japanese, see "" nlg
autocmd BufRead,BufNewFile *{jaAc,jlpt}* nnoremap <buffer> <silent> * :<C-u>call Search_ja_cword()<CR>
autocmd BufRead,BufNewFile *{jaAc,jlpt}* nnoremap <buffer> <silent> <space>j :<C-u>call Ag_search("-G [^-]ja[^npvc] ".Cword_japanese(),0,1)<CR>
autocmd BufRead,BufNewFile *{jaAc,jlpt}* vnoremap <buffer> <silent> K :<C-u>sil call Ag_search("-G [^-]ja[^npvc] ".Cword_japanese(),0,1)<CR>
" autocmd BufRead,BufNewFile *{jaAc,jlpt}* vnoremap <buffer> <silent> K :<C-u>call Ag_search("-G [^-]ja[^vc] ".getline('.')[getpos("'<")[2]-1:getpos("'>")[2]-1],0,1)<CR>|" not work for multibyte character
autocmd Filetype janlg nnoremap <buffer> <silent> * :<C-u>call Search_ja_cword()<CR>
" autocmd Filetype janlg nnoremap <buffer> <silent> <space>j :<C-u>call Ag_search("-G (?\!aa-\|android/)ja[^vc] ".Cword_japanese(),0,1)<CR>
autocmd Filetype janlg nnoremap <buffer> <silent> <space>j :<C-u>call Ag_search("-G (?=aa-)ja[^npvc] ".Cword_japanese(),0,1)<CR>

func! Search_ja_cword() range
    let word = Cword_japanese()
    let @/ = (strgetchar(word,0) > 255)? word : '\<'.word.'\>'
    for i in range(v:count1)
        call search(@/)
    endfor
endfunc
func! Cword_japanese()
    let line = getline('.')
    if mode() ==# 'v'
        return line[getpos("'<")[2]-1:getpos("'>")[2]-1]
    endif
    let rest = matchstr(line, '\%'.col('.').'c.*')
    let c = strgetchar(rest,0)
    if c > 255
        let ind = strridx(line,rest)
        let pre = strpart(line,0,ind)
        let lword = matchstr(pre,'[\u3000-\u9faf]\+$') " pattern https://stackoverflow.com/a/30200250/3625404
        let rword = matchstr(rest,'^[\u3000-\u9faf]\+')
        return lword.rword
    else
        return expand('<cword>')
    endif
    " echo rest.']['.c.']['.ind.']['.pre.']['.lword .']['.lword.rword
endfunc


    " undo
    " jump " mark
"ls, see " edit 
    " init " invoke " quit " session
    " lang " code " nlg
    " tag
    " tmux

"env, see " run
" let $BASH_ENV="$HOME/notes/.bvimbrc"    " see " invocation in bash.scp
exec 'let $BASH_ENV="'.expand('<sfile>:p:h').'/.bvimbrc"'   |" compatible for root users too.
" let $CFLAGS='-Wparentheses'
" let $CXXFLAGS
" export PYTHONSTARTUP=~/.pythonrc.py  https://stackoverflow.com/questions/4837237/pythonrc-py-is-not-loading-in-interactive-mode
" let $PYTHONSTARTUP='~/notes/rc/pythonrc.py'
exec 'let $PYTHONSTARTUP="'.expand('<sfile>:p:h').'/rc/pythonrc.py"'

"lang, see "" ls " ahk " python " c " cpp " code

" test numpy/ma/core.py  -- not work yet
func! RemoveDocString_python() abort
    let prev = 0
    " norm! G$
    $pu_
    while 1
" let @q='/"""*\Ve/"""\s*$\"_d'
" :/pat is different from `norm! /pat`, former's column depend on previous position.
        /"""\+
        " sil! norm! /"""\+\
        if prev >= line('.')
            break
        endif
        let prev = line('.')
        if match(getline('.'), '^\s*r\?"""') != 1
            " norm! Ve/"""\s*$\"_d
            norm! Vn"_d
" let @q='nVn"_d'
            " mark y
            " sil! norm! /"""\s*\
            " 'y,.d_
        else
            norm! 2n
        endif
    endwhile
endfunc

func! Py_retain_header(...) abort
    let arg1 = get(a:, 1, '00')
    if arg1 == 'def'
    elseif arg1 == 'class'
    elseif arg1 == 'import'
    endif
endfunc

let g:py_ntabs = 4
func! Py_retain_only_method_def(...) abort
    mark p
    let arg1 = get(a:, 1, '00')
    let noprivate = arg1[0]
    let all = arg1[1]
    let g:a = '['.noprivate.'] ['.all.']'
    " return
    if all == '' || all == '0'
    " if all == '0'
        let pos_cur = line('.')
        let pos = search('^class','bcn')    " get line number, no move cursor
        if pos == 0
            return
        elseif pos > pos_cur
            call search('^class')
        else
            exec pos
        endif
        sil 1,.-d_
        if search('^\S') > 1
            sil .+,$d_
        endif
    endif
    " 3 == 0 + 4 == 1 + 5, 4 == 2 + 5   | 2:__  5: _[^_] 4: _*
    if g:py_ntabs == 2 || (exists('b:py_ntabs') && b:py_ntabs == 2)
        if noprivate == '0'       " no private
            sil 2,$v/^\%(\t\| \{2\}\)\(class\|def\) [A-Za-z]\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '1'   " interface, __ or \w*
            sil 2,$v/^\%(\t\| \{2\}\)\(class\|def\) \%(__\|[A-Za-z]\w\)\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '2'   " only __*
            sil 2,$v/^\%(\t\| \{2\}\)\(class\|def\) __\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '3'   " all
            sil 2,$v/^\%(\t\| \{2\}\)\(class\|def\) [_A-Za-z]\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '4'   " only _*
            sil 2,$v/^\%(\t\| \{2\}\)\(class\|def\) _\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        else                    " only _[^_]*
            sil 2,$v/^\%(\t\| \{2\}\)\(class\|def\) _[0-9A-Za-z]\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        endif
    else
        if noprivate == '0'       " no private
            sil 2,$v/^\%(\t\| \{4\}\)\(class\|def\) [A-Za-z]\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '1'   " interface, __ or \w*
            sil 2,$v/^\%(\t\| \{4\}\)\(class\|def\) \%(__\|[A-Za-z]\w\)\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '2'   " only __*
            sil 2,$v/^\%(\t\| \{4\}\)\(class\|def\) __\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '3'   " all
            sil 2,$v/^\%(\t\| \{4\}\)\(class\|def\) [_A-Za-z]\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        elseif noprivate == '4'   " only _*
            sil 2,$v/^\%(\t\| \{4\}\)\(class\|def\) _\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        else                    " only _[^_]*
            sil 2,$v/^\%(\t\| \{4\}\)\(class\|def\) _[0-9A-Za-z]\w*(.*\(\_$\n\_^[^)]*\)\{-}):/d_
        endif
    endif
    " if all != '0'
    if !(all == '' || all == '0')
        1d_
    endif
endfunc
command! -nargs=* M sil call Py_retain_only_method_def(<f-args>)
nnoremap ;m :M 
call CmdAlias('m',' M')

augroup go_lang
    autocmd!
augroup END " go_lang

" https://github.com/nvie/vim-flake8
" autocmd BufWritePost *.py call Flake8()
" *interesting*  https://github.com/python-mode/python-mode
"python, see " lang " ag " env
" if  | echo 'true' | else | echo 'false' | endif
    " let $PYTHON_EXE='C:/pkg/dt/python3.7.4/python.exe'
    if $PYTHON_EXE =~ '^[-_. :/a-zA-Z0-9]\+$'
        " echo 'match'
        let s:python_exe = $PYTHON_EXE
    else
        " echo 'not match'
        let s:python_exe = 'python3'
    endif
func! VerifyPyExeThenRun(file) abort
    let pyexe = get(b:, 'pyexe', $PYTHON_EXE)
    if pyexe !~# '^[-_. :/a-zA-Z0-9]*python[0-9.]*\(\.exe\)\?$'
    " echo 'C:/pkg/dt/python3.7.4/python.exe' !~# ''
        let pyexe = 'python3'
    endif
    let py_opt = (has_key(b:, 'py_opt') ? b:py_opt : get(g:, 'py_opt', ''))
    if py_opt !~# '^-["'' a-z-]\+$'     " -m pdb -c 'until 33'
        let py_opt = ''
    else
        let py_opt = escape(py_opt, "\"'")
    endif
    let py_redir = (has_key(b:, 'py_redir') ? b:py_redir : get(g:, 'py_redir', ''))
    echom "[py_redir]" py_redir
    let py_redir = (py_redir =~# '^[-_ ./:0-9a-zA-Z]\+$') ? (" > '" . py_redir . "'") : ''
    echom "[py_redir]" py_redir "after"
    let file = substitute(a:file, '^/cygdrive/\([c-z]\)/', '\1:/', '')
    let cmd = '!"' . pyexe . '" ' . py_opt . ' "' . file . '"' . py_redir
    echom "cmd [" . cmd . "]"
    exec cmd
endfunc " VerifyPyExeThenRun
augroup python_lang
    autocmd!
    autocmd Filetype python nn <buffer> <space>r :<C-u>call VerifyPyExeThenRun(expand('%'))<CR>
" C:\pkg\dt\Anaconda3\ipython.exe
    " autocmd Filetype python vnoremap <buffer> <space>r :call REPL_SendLines()<CR>
    autocmd Filetype python nnoremap <buffer> ]v :v/^\(class\\|def\) \w\+(.*\(\_$\n\_^[^)]*\)\{-}):/d_<CR>
    autocmd Filetype python nnoremap <buffer> ]d :<C-u>call Py_retain_only_method_def(0)<CR>
    autocmd filetype python nnoremap <buffer> ;c mo:set opfunc=RemovePythonComments<CR>g@
    autocmd filetype python vnoremap <buffer> ;c :<C-u>call RemovePythonComments(visualmode())<CR>
    " autocmd Filetype python nnoremap <buffer> u u`p
    autocmd Filetype python nnoremap <buffer> <Leader>p :.w !python<CR>
    autocmd Filetype python nnoremap <buffer> <Leader>p :.w !python<CR>
    command! -nargs=* Psd :r!sdefag "<args>"
        autocmd Filetype python nnoremap <buffer> ;d :r!sbdefag <cword><CR>
    " autocmd Filetype python setl path+=/usr/local/lib/python2.7/dist-packages/
    " autocmd BufRead python.plg setl path+=/usr/local/lib/python2.7/dist-packages/
    " autocmd BufRead python.plg nnoremap <buffer> qr :.w !python<CR>
    " below, first line as initial part of python code, eg, import necessary modules
    autocmd BufRead python.plg nnoremap <buffer> qr :.w !cat <(head -1 %) /dev/stdin \|python -<CR>
    autocmd BufRead {numpy,sympy}.ulib nnoremap <buffer> qr :.w !cat <(head -1 %) /dev/stdin \|python -i -<CR>
    " autocmd BufRead python.plg nnoremap <buffer> qr :.w !cat <(head -10 %\|grep '^\s*(import\|from)') /dev/stdin \|python -<CR>
    " -- or use ipython with customized profile file?
    autocmd Filetype python inorea <buffer> dbp import ipdb as pdb; pdb.post_mortem()
    autocmd Filetype python inorea <buffer> dbs import ipdb as pdb; pdb.set_trace()
augroup END " python_lang
" autocmd Filetype python inoremap <buffer> <F5> <C-o>:update<Bar>execute '!python '.shellescape(@%, 1)<CR>
" nnoremap <Leader>p :'<,'>w !python<CR>
" nnoremap <Leader>p :'<,'>w! ~/.codepython<CR>:!python -i ~/.codepython<CR>
" nnoremap <Leader>d :6,.w ~/.codepython<CR>:!ipython --quick --no-banner --no-confirm-exit -i ~/.codepython<CR>
" nnoremap <Leader>d :exec '!ipython -i '.expand('%:p')<CR>

func! _DoNoteCallThis()
    return
python << EOL
import vim, StringIO,sys        # http://vim.wikia.com/wiki/Execute_Python_from_within_current_file
def PyExecReplace(line1,line2):     # and https://github.com/vim-scripts/Execute-selection-in-Python-and-append/blob/master/plugin/pythonExecuteAppendOrReplace.vim
  r = vim.current.buffer.range(int(line1),int(line2))
  redirected = StringIO.StringIO()
  sys.stdout = redirected
  exec('\n'.join(r) + '\n')
  sys.stdout = sys.__stdout__
  output = redirected.getvalue().split('\n')
  r[:] = output[:-1] # the -1 is to remove the final blank line
  redirected.close()
EOL
command! -range Pyer python PyExecReplace(<f-line1>,<f-line2>)
endfunc

"plg, "bks, see " file
autocmd BufRead,BufNewFile *.scp setf txt
autocmd BufRead,BufNewFile *.bks setlocal cms=\"%s
autocmd Filetype sh,c,java,cpp inoremap <buffer> ; ;
autocmd Filetype sh,c,java,cpp inoremap <buffer> : :
autocmd Filetype scheme nnoremap <buffer> <space>r :.w !scheme \| tail -n+9 > ~/.tmprun<CR><CR>:redraw!<CR>
autocmd Filetype scheme nnoremap <buffer> <space>p :.w !guile \| tail -n+9 > ~/.tmprun<CR><CR>:redraw!<CR>

"c, see " lang
augroup C_lang
    autocmd!
    autocmd BufRead C-macro.plg setf c
    autocmd Filetype c set path+=/usr/include/x86_64-linux-gnu/  " for eg bits/types.h
    autocmd Filetype cpp set path+=/usr/include/x86_64-linux-gnu/  " for eg bits/types.h, some *.h ft been set to cpp.
    autocmd Filetype c nnoremap <buffer> <space>m :make %:p:r<CR><CR>
    autocmd Filetype c nnoremap <buffer> <space>r :exec '!cd '.expand('%:p:h').' && ./'.expand('%:t:r')<CR>
    autocmd filetype c,cpp nnoremap <buffer> ;c mo:set opfunc=RemoveCComments<CR>g@
    autocmd Filetype c call Setup_plg()
augroup END " C_lang
"cpp, see " lang " make
" inorea dvec std::vector<int>
augroup cpp_lang
    autocmd!
" autocmd FileType cpp setlocal makeprg=make -std=c++11
" autocmd Filetype cpp nnoremap <buffer> <space>m :make -std=gnu++11 %:p:r<CR><CR>
    autocmd Filetype cpp nnoremap <buffer> <silent> <space>m :lcd %:p:h<CR>:exec 'make '.expand('%:t:r')<CR><CR>
    autocmd Filetype cpp nnoremap <buffer> <space>r :<C-u>!%:p:r<CR>
    " a func to make map based content last line and name
"make-and-run, see " env(CFLAGS)
" used in conjunction with Makefile, syn tools like nutstore or git.
    autocmd FileType make call Setup_plg()
autocmd Filetype cpp inorea ivec std::vector<int>
autocmd Filetype cpp inorea tvec std::vector<T>
autocmd Filetype cpp inorea pvec std::vector<std::pair<int,int>>
autocmd Filetype cpp inorea svec std::vector<std::string>
autocmd Filetype cpp inorea ssvec std::vector<std::vector<std::string>>
autocmd Filetype cpp inorea svecc std::vector<std::vector<std::string>>
autocmd Filetype cpp inorea svvec std::vector<std::vector<std::string>>
autocmd Filetype cpp inorea ivvec std::vector<std::vector<int>>
autocmd Filetype cpp inorea ivecc std::vector<std::vector<int>>
autocmd Filetype cpp inorea dvec std::vector<double>
autocmd Filetype cpp inorea llvec std::vector<long long>
autocmd Filetype cpp inorea szt size_t
augroup END " cpp_lang

" ~/.make.rust
" !cd && ln -s %:p:h/rc/make/.make.rust .
" %: %.rs
    " rustc $^
augroup Rust_lang
    au!
    autocmd filetype rust nnoremap <buffer> <space>r :<C-u>!cargo run <bar><bar> ./%:r<CR>
    autocmd filetype rust nnoremap <buffer> <space>m :<C-u>!cargo build <bar><bar> make -f ~/.make.rust %:r<CR>
augroup END " Rust_lang

"tmux, see " ls
command! -nargs=* Tmm sil call system('tmux split-window -c '.expand('%:p:h')." <args>")
call CmdAlias('tmm',' Tmm')
call CmdAlias('tm',' Tmm')
" command! -nargs=* Tmm sil! call system('tmux split-window -c '.expand('%:p:h').len(<q-args>) > 0? " -c ".<q-args> : "")
" command! -nargs=* Tmm sil! call system('tmux split-window -c '.expand('%:p:h').len(expand(<q-args>)) > 0? " -c ".expand(<q-args>) : "")
" command! -nargs=* Eargs echo len(<q-args>) > 0? " -c ".<q-args> : ""
" autocmd FileType cpp setlocal keywordprg=tmux\ split-window\ cppman 
" autocmd FileType cpp nnoremap <silent><buffer> K <Esc>:silent! call system(" tmux split-window cppman ". expand('<cword>'))<CR> 
" autocmd FileType cpp setlocal keywordprg=:te\ cppman
command! -nargs=+ Cppman silent! call system(" tmux split-window cppman " . expand(<q-args>))
autocmd FileType cpp nnoremap <silent><buffer> K <Esc>:Cppman <cword><CR>
" https://www.reddit.com/r/vim/comments/3oo1e0/has_anyone_found_a_way_to_make_k_useful/
" autocmd FileType cpp setlocal keywordprg=cppman
" autocmd FileType cpp nnoremap <buffer> K K<CR>

"java
augroup java_lang
    autocmd!
    autocmd filetype java nnoremap <buffer> ;c mo:set opfunc=RemoveCComments<CR>g@
    " if stridx($PWD, 'src') >= 0 || stridx($PWD, 'java/') >= 0
    if stridx($PWD, '/java') >= 0
        autocmd Filetype java setl tags+=$HOME/java/src_jdk1.8.0_60/java/tags
    endif
    autocmd Filetype java nnoremap <buffer> <space>r :lcd %:p:h<CR>:exec '!java '.expand("%:t:r")<CR>
    " autocmd Filetype java nnoremap <buffer> <space>r :!java -cp %:p:h %:t:r<CR>
    " *errorformat-javac* below from http://stackoverflow.com/a/14727153/3625404
    autocmd Filetype java setlocal errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
    " http://stackoverflow.com/a/6412418/3625404
    autocmd Filetype java compiler javac
    " autocmd Filetype java setlocal makeprg=javac\ -d\ _test\ -cp\ _test\ %
    autocmd Filetype java setlocal makeprg=javac\ %<.java
    autocmd Filetype java :setlocal errorformat=%A%f:%l:\ %m,%-Z%p^,%Csymbol\ \ :\ %m,%-C%.%#
    " -- from http://vim.wikia.com/wiki/Compile_Java_with_Sun_JDK_javac
    autocmd Filetype java nnoremap <buffer> <silent> <space>m :make<CR>:let nerr = len(filter(getqflist(),'v:val.valid')) \| if nerr \| copen \| endif<CR>
    " autocmd Filetype java nnoremap <buffer> <space>m :!javac %:p<CR>
    " TODO use g:nerr in statusline of quickfix window
    " if len(filter(getqflist(),'v:val.valid')) | echo "non empty" | else | echo "empty" | endif
autocmd Filetype java inorea psvm public static void main(String[] args) {}kfn
autocmd Filetype java inorea println System.out.println
augroup END " java_lang

func! TogOnDiff() abort
    if winnr('$') == 2
        " let oldwin = winnr()
        diffthis
        wincmd w
        diffthis
        wincmd w
    endif
endfunc
func! TogOffDiff() abort
    if winnr('$') == 2
        " let oldwin = winnr()
        diffoff
        wincmd w
        diffoff
        wincmd w
    endif
endfunc

"diff, 
set diffopt+=vertical
nnoremap <F4> :if &diff\|sil! close\|diffoff!\|else\|diffsplit #\|endif<CR>
nnoremap <F4> :<C-u>call Toggle_diff_alternate_buffer()<CR>
func! Toggle_diff_alternate_buffer() abort
    "-- feature: possibly return to previous position.
    if &diff
        diffoff!
        if winnr('$') > 1
            close
        endif
        set noscrollbind nocursorbind nocursorcolumn nocursorline
    else
        vsp
        b #
        diffthis
        set scrollbind cursorbind cursorcolumn cursorline
        winc p
        diffthis
        set scrollbind cursorbind cursorcolumn cursorline
        winc p
    endif
endfunc

" "fn, see "" file
" " call graphical file manager
" if executable('explorer')
" command! -nargs=? FM !explorer <args> &
" endif
" command! -nargs=? VV e %:p:h/<args>
" call CmdAlias('le', 'VV')
" command! -nargs=? TMUX !tmux neww -c %:p:h/<args>
" call CmdAlias('tmux', 'TMUX')
" " also config dirvish to achieve same func


"file, filetype, suffixes, see " autocmd " source " suffixes " plg(bks)
"   fn
autocmd BufRead,BufNewFile ~/*.tmp* setlocal noswapfile
autocmd BufRead,BufNewFile *.mf set filetype=txt
autocmd BufRead,BufNewFile *.build set filetype=xml
autocmd BufRead,BufNewFile .pathogen set filetype=vim
autocmd BufRead,BufNewFile .bvimbrc set filetype=sh
autocmd BufRead,BufNewFile cplus.plg setlocal keywordprg=cppman |sil! exec 'nunmap K'
autocmd BufRead,BufNewFile .tmux.conf set filetype=sh
"large("big) file, 
au BufReadPost *        if getfsize(bufname("%")) > 4*1024*1024 |
\                               set syntax= |
\                       endif

"sql
autocmd Filetype sql inorea orderby ORDER BY
autocmd Filetype sql inorea desc DESC
autocmd Filetype sql inorea where WHERE
autocmd Filetype sql inorea between BETWEEN
autocmd Filetype sql inorea and AND
autocmd Filetype sql inorea or OR
autocmd Filetype sql inorea is IS
autocmd Filetype sql inorea null NULL
autocmd Filetype sql inorea select SELECT
autocmd Filetype sql inorea from FROM
" autocmd Filetype sql nnoremap <buffer> <space>r :.w! ~/.tmpsql<CR>:!mysql  -u qeatzy -pxyz -D bank -t < ~/.tmpsql<CR>
" autocmd BufRead /cygdrive/e/notes/sql.plg nnoremap <buffer> <space>r :.w! ~/.tmpsql<CR>:!mysql  -u qeatzy -pxyz -D bank -t < ~/.tmpsql<CR>
autocmd Filetype sql nnoremap <buffer> <space>r :.w! ~/.tmpsql<CR>:!mysql  -u sam -pxyz -D sam -t < ~/.tmpsql<CR>
autocmd BufRead /cygdrive/e/notes/sql.plg nnoremap <buffer> <space>r :.w! ~/.tmpsql<CR>:!mysql  -u sam -pxyz -D sam -t < ~/.tmpsql<CR>

let g:dbext_default_profile_mysql_local = 'type=MYSQL:user=qeatzy:passwd=xyz:dbname=bank'

"markdown, "md
" w!~/.tmpmarkdown | !/home/qeatzy/anaconda2/envs/py3/bin/retext ~/.tmpmarkdown
nnoremap ,m :w!~/.tmpmarkdown<CR>:!/home/qeatzy/anaconda2/envs/py3/bin/retext ~/.tmpmarkdown &<CR>
vnoremap ,m :w!~/.tmpmarkdown<CR>:!/home/qeatzy/anaconda2/envs/py3/bin/retext ~/.tmpmarkdown &<CR>

"ahk, see "" lang
augroup ahk
    autocmd!
    autocmd FileType autohotkey nnoremap <buffer> <space>r :!"D:/Program Files/AutoHotkey/AutoHotkeyU32.exe" % &<CR>
    autocmd FileType autohotkey inorea msgbox MsgBox
    autocmd FileType autohotkey inorea mb MsgBox
augroup END

" t l p y used in .vimrc and .utility.vim
""marks
nnoremap <special> <C-'> :marks<CR>
nnoremap '' ``
nnoremap mq mQ
nnoremap 'q `Q
nnoremap mw mW
nnoremap 'w `W
nnoremap me mE
nnoremap 'e `E
nnoremap mr mR
nnoremap 'r `R
nnoremap mt mT
nnoremap 't `T
nnoremap ma mA
nnoremap 'a `A
nnoremap ms mS
nnoremap 's `S
nnoremap md mD
nnoremap 'd `D
nnoremap mf mF
nnoremap 'f `F
nnoremap mg mG
nnoremap 'g `G
nnoremap mz mZ
nnoremap 'z `Z
nnoremap mx mX
nnoremap 'x `X
nnoremap mc mC
nnoremap 'c `C
nnoremap mv mV
nnoremap 'v `V
nnoremap mb mB
nnoremap 'b `B
"map 'v <Nop>


func! CmdAnotherWindow(cmd)
    if winnr('$') < 2 | return | endif
    if (winnr('#') && winnr() != winnr('#')) | winc p | else | winc w | endif
    exec a:cmd
    winc p
endfunc
func! VarToggle(varname,value)
    if exists(a:varname)
        exec 'unlet ' . a:varname
    else
        exec 'let ' . a:varname . ' = ' . a:value
    endif
endfunc
func! MapTogPreview()
    if maparg('j','n') == ""
        " nnoremap <buffer><silent> j <C-\><C-n>j:call feedkeys("p")<CR>
        " nnoremap <buffer><silent> k <C-\><C-n>k:call feedkeys("p")<CR>
        nnoremap <buffer><silent> j j:call feedkeys("p")<CR>
        nnoremap <buffer><silent> k k:call feedkeys("p")<CR>
        " nnoremap d <C-w>p<C-f><C-w>p
        " nnoremap <buffer><silent><expr> d CmdAnotherWindow("norm! <C-F>")<CR>
        " nnoremap <buffer><silent> d :<C-u>call CmdAnotherWindow("norm! \")<CR>
        nnoremap <buffer><silent> d :<C-u>call CmdAnotherWindow("norm! " . v:count1 ."\006")<CR>
        nnoremap <buffer><silent> s :<C-u>call CmdAnotherWindow("norm! " . v:count1 ."\002")<CR>
    else
        nunmap <buffer><silent> j
        nunmap <buffer><silent> k
        nunmap <buffer><silent> d
        nunmap <buffer><silent> s
    endif
endfunc

let s:hasFileManger={}
func! FileManger(filename, ...) abort
    let fn = substitute(a:filename, '/*$','','')
    if filereadable(fn)
        let fn = fnamemodify(fn,':h')
    endif
    let cmd = get(a:000, 0, 'ranger')
    if !has_key(s:hasFileManger, cmd)
        let s:hasFileManger[cmd] = executable(cmd)
    endif
    " echo s:hasFileManger[cmd]  isdirectory(fn)
    if s:hasFileManger[cmd] && isdirectory(fn)
        " echo (cmd . shellescape(fn))
        exec '!' cmd  shellescape(fn)
    endif
endfunc

func! InitDirvish()
    if &ft != 'dirvish' | return | endif
    " have effect only when both condition true or false,
    " achieve toggle behavior with `VarToggle('g:dirvish',1)`
    if exists('g:dirvish') == (maparg('j','n') == "")
        call MapTogPreview()
    endif
    setl cole=3
endfunc
func! GetInputPattenThenFilter()
    let pat = GetInput('pattern to filter: ')
    let cmd = 'g'
    let start = 0
    let dirvish_mode = 0
    if pat[0] == '	'   |" leading <tab>
        let dirvish_mode = 1
        let start = 1
        if pat[1] == '	'   |" 2nd leading <tab>
            if pat[2:] == '	' | unlet g:dirvish_mode | return | endif  |" triple leading <tab> 
            let cmd = 'v'
            let start = 2
        elseif pat[1] == ' ' |" space
            let cmd = 'v'
            let start = 2
            let dirvish_mode = 0
        endif
    endif
    if len(pat) <= start | return | endif
    if dirvish_mode
        let g:dirvish_mode = ':sil! keeppatterns ' . cmd . '@' . pat[start:] . '@d_'
        e! %
    else
        exec 'sil! keeppatterns ' . cmd . '@' . pat[start:] . '@d_'
    endif
endfunc
"dirvish
" polyfill to below lines in ~/.vim/bundle/vim-dirvish/ftplugin/dirvish.vim
" nnoremap <buffer> / /^.*[/]\zs.\{-\}
" nnoremap <buffer> ? ?^.*[/]\zs.\{-\}
" and unmap <buffer> q
" polyfill dirvish#open (actually s:open_selected()) to handle file not exist case.
    " if !isdirectory(path) && !filereadable(path)
    "     if len(paths) > 1 | continue | endif    |" `continue` originally
" -- then <space>d duplicate line, -- modify to new file name, -- `i` to open it.
" -- change continue to 'if len(paths) > 1 | continue | endif'
augroup dirvish_config
    autocmd!
    " autocmd FileType dirvish nnoremap <silent><buffer> t :call dirvish#open('tabedit', 0)<CR>
    autocmd FileType dirvish nnoremap <silent><buffer> r :<C-u>call FileManger(getline('.'),'ranger')<CR>
    autocmd FileType dirvish nnoremap <silent><buffer> ;d :<C-u>v=/$=d_<CR>
    " autocmd FileType dirvish nnoremap <silent><buffer> <F4> :<C-u>call MapTogPreview()<CR>
    " autocmd FileType dirvish nnoremap <silent><buffer> <F4> :<C-u>ky \| call VarToggle('g:dirvish',1) \| e<CR>`y
    autocmd FileType dirvish nnoremap <silent><buffer> <F4> :<C-u>call VarToggle('g:dirvish',1) \| set ft=dirvish<CR>
    autocmd FileType dirvish nnoremap <silent><buffer> <C-x> <C-w>x
    autocmd FileType dirvish nnoremap <silent><buffer> x :<C-u>call GetInputPattenThenFilter()<CR>:setl cole=3<cr>
    autocmd FileType dirvish call InitDirvish()
    " hide .* files
      autocmd FileType dirvish nnoremap <silent><buffer>
        \ gh :silent keeppatterns g@\v/\.[^\/]+/?$@d _<cr>:setl cole=3<cr>
augroup END
" let g:dirvish_relative_paths = 1
    " let g:dirvish_mode = ':silent keeppatterns g@\v\.exe/?$@d _'

func! CmdRange(cmd) abort
    sil! exe "normal! '[V']" . '"_y'
    " sil! exe "normal! '[V']y"
    let beg = getpos("'<")[1]
    let end = getpos("'>")[1]
    exec "sil! " . beg . "," . end . a:cmd
    call setpos('.', g:save_pos)
    " norm! g`o
endfunc

func! RemoveEmptyLines(type, ...) abort
    call CmdRange('g/^\s*$/d_')
endfunc

func! RemoveDoubleEmptyLines(type, ...) abort
    call CmdRange('g/^\_$\n\_^$/d_')
endfunc

" https://vi.stackexchange.com/questions/12555/how-to-allow-count-before-my-custom-operator
func! Op_pos(opfunc)
let g:save_pos = getcurpos()
exec 'set opfunc='. a:opfunc
return 'g@'
endfunc

"g, (:g)
nnoremap \d :g//d_<CR>
nnoremap \v :v//d_<CR>
nnoremap gb :s/  \+/ /g<CR>|" b for blank, remove extra blank.
nnoremap gs :g//p<CR>|" print all match of previous search
" show all tag-of-notes (line begin with comma + non space)
nnoremap g" :%v/^"[^ ]/d_<CR>
"below delete multiple empty lines, http://stackoverflow.com/a/726158/3625404, http://stackoverflow.com/a/706085/3625404, http://vim.wikia.com/wiki/Remove_unwanted_empty_lines
nnoremap <expr> \e Op_pos('RemoveDoubleEmptyLines')
" nnoremap gm :g/^\s*$/d_<CR>
" nnoremap gm :call setpos("'o",getcurpos()) \| set opfunc=RemoveEmptyLines<CR>g@
" nnoremap gm :let g:save_pos = getcurpos() \| set opfunc=RemoveEmptyLines<CR>g@
nnoremap <expr> gm Op_pos('RemoveEmptyLines')

" if exists(':TComment')      -- not work, vimrc loaded **before** plugins. test for file exists instead. see " rc in edit.plg for more.
if filereadable(expand("~/.vim/bundle/tcomment_vim/.gitignore"))
nnoremap g[ :TComment<CR>
elseif filereadable(expand("~/.vim/bundle/vim-commentary/.gitignore"))
nnoremap g[ :Commentary<CR>
endif
"cms, "comment, 1. plugin 2. native, helpful when scripts/plugin unaccessible or not work properly
" nnoremap <F10> a<Esc>:call ToggleComment()<CR><Esc>
nmap g/ gc
"below gC map to block comment in C-style. not work properly, from http://vim.wikia.com/wiki/Commenting_out_a_range_of_lines
map gC :'a,. s/^/ */^M:. s/\(.*\)/\1^V^V^M **************\//^M:'a s/\(.*\)/\/**************^V^V^M\1/^M
" refto http://stackoverflow.com/questions/1676632/whats-a-quick-way-to-comment-uncomment-lines-in-vim
" toggle line comment, C++ style, refto http://stackoverflow.com/questions/11868538/vim-inline-remap-to-check-first-character
function! ToggleComment()
let pos=getpos(".")
let win=winsaveview()
if getline(".") =~ '\s*\/\/'
    normal! ^2x
    let pos[2]-=1
else 
    normal! ^i//
    let pos[2]+=3
endif
call winrestview(win)
call setpos(".",pos)
startinsert
endfunction   

func! LocalWindowStatusline()
setlocal statusline=''
setlocal statusline+=%7*\[%n]
setlocal statusline+=%1*\ %<%F\ 
setlocal statusline+=%2*\ %y\ 
setlocal statusline+=%8*\ %=\ %l/%L\ [%02p%%]
setlocal statusline+=%9*\ %03c\ 
setlocal statusline+=%0*\ %m%r%w\ %P\ 
endfunc

function! MarkWindowSwap()
unlet! g:markedWin1
unlet! g:markedWin2
let g:markedWin1 = winnr()
normal my
endfunction

function! DoWindowSwap()
if exists('g:markedWin1')
    if !exists('g:markedWin2')
        let g:markedWin2 = winnr()
        normal my
    endif
    let l:curwin = winnr()
    let l:bufWin1 = winbufnr(g:markedWin1)
    let l:bufWin2 = winbufnr(g:markedWin2)
    exec g:markedWin2 . 'wincmd w'
    exec ':b '.l:bufWin1
    exec g:markedWin1 . 'wincmd w'
    exec ':b '.l:bufWin2
    " exec l:curwin . 'wincmd w'
    :2winc w
endif
endfunction

"alt, see " kb
" How to map Alt key?
" 1. (break terminal window <M-f>) polyfil keycode  https://vi.stackexchange.com/a/2363/10254
" 2. (preferred, need to manually check what <M-f> produce) map directly https://vi.stackexchange.com/a/18080/10254
"   use <C-v> (or <C-q>) to get raw key input. :h i^v

" How do I set the default window size in vim?  https://superuser.com/questions/419372/how-do-i-set-the-default-window-size-in-vim
" set lines=64
" set columns=90
"gvim, see " .gvimrc
if has("gui_running")
winpos 130 662
" winsize 100 200   " obsolete
set lines=55
set columns=90
endif

"end
:finish  " the rest of this script will be ignored.

function! SetReadonlyLess(...)
if a:0 == 0
    exec 'setl '.'nomodifiable'
    exec 'nnoremap '.'<buffer> u zb2<C-e><C-b>zt2<C-y>'
    exec 'nnoremap '.'<buffer> s zb2<C-e><C-b>zt2<C-y>'
    exec 'nnoremap '.'<buffer> d zt2<C-y><C-f>zt2<C-y>'
    exec 'nnoremap '.'<buffer> i zt2<C-y><C-f>zt2<C-y>'
    exec 'nnoremap '.'<buffer> sd zt2<C-y><C-f>zt2<C-y>'
    exec 'nnoremap '.'<buffer> o <C-u>'
    exec 'nnoremap '.'<buffer> a <C-u>'
    exec 'nnoremap '.'<buffer> c <C-d>'
    exec 'nnoremap '.'<buffer> p <C-d>'
else
    exec 'silent! '.'nunmap <buffer> u'
    exec 'silent! '.'nunmap <buffer> s'
    exec 'silent! '.'nunmap <buffer> d'
    exec 'silent! '.'nunmap <buffer> i'
    exec 'silent! '.'nunmap <buffer> o'
    exec 'silent! '.'nunmap <buffer> a'
    exec 'silent! '.'nunmap <buffer> c'
    exec 'silent! '.'nunmap <buffer> p'
    if a:1 == 'modifiable'
        exec 'setlocal '.'modifiable'
    endif
endif
endfunction

nnoremap <F6> :call SetReadonlyLess()<CR>
nnoremap 6<F6> :call SetReadonlyLess('modifiable')<CR>
nnoremap 3<F6> :call SetReadonlyLess('modifiable')<CR>
nnoremap g<F6> :call SetReadonlyLess('modifiable')<CR>

" some keys are indisguishable in vim, eg. <C-i> and <Tab>, <C-m> and <CR>
" some keys are unrecognizable by vim, eg, <C-,> <C-.> <C-;>
"unusable key, try to define keymap with ahk, possibly swap with hard-to-type keys
"+ <C-;> <C-/> <C-'> <C-,> <C-.>
" if in insert mode, effect of typing two key is the same, then they are probabily the same key in vim
" if in insert mode, no effect for some key, then probabily they can't be recognized by vim

" .vimrc
" .utility.vim .plugin.vim swo/vim.soc
