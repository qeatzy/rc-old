" ln -s $(realpath postvimrc.vim) ~/.vim/after/plugin/postvimrc.vim

func! ChangeTermColor(...)
    " echo join(a:000,' ')
    exec 'sil !python3 ~/notes/task/color/themes_raw.py ' . join(a:000,' ') . ' </dev/null'
    redraw!
    " py3 sys.argv = [''] + vim.eval('a:000')
    " py3f ~/notes/task/color/mtc.py
endfunc
" 
command! -nargs=* CO call ChangeTermColor(<f-args>)
" h <args>
call CmdAlias('co',' CO')

if !has('s:has_color_vanilla')
    try
        colorscheme vanila
        let s:has_color_vanilla = 1
    catch /E185/
        let s:has_color_vanilla = 0
    endtry
elseif s:has_color_vanilla
    colorscheme vanila
endif

func! VimLinesCapture(lno, n) abort
    let out = Capture(join(getline(a:lno, a:lno + a:n - 1),"\n"))
    call WinScratch('b','',g:sz_scratch, exists('b:cpurge') ? b:cpurge : g:cpurge)
    pu=out
    if g:st_winback
        winc p
    endif
endfunc

sil! delc Explore

cnoremap <C-k> <Up>

" {{{ ic-object.vim
func! Ic_Object(cnt, pat) abort
    let pos = match(getline('.'), a:pat, 0, a:cnt)
    " echo match(getline('2'),  '\<\w\+\S\{-1,\}', 0, 2)
    " echom [a:cnt, pos]
    call cursor([0,pos+1])
    norm! ve
endfunc

onoremap ic :<C-u>call Ic_Object(v:count1, '\<\w\+\S\{-1,\}')<CR>
" }}} ic-object.vim
