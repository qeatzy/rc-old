"bks
" align chapters in TOC, seperated by 3 or more dots.
command! -nargs=1 AlignTOC %s/^\(.* \)\.\{3,\}\( [0-9ivx]\+\)$/\=submatch(1).repeat('.',<args>-len(submatch(1))-len(submatch(2))).submatch(2)/
" contents in  xx.logmf
func! NextChapter() range
    " or test existence of b:pat_chapter
    for i in range(v:count1)
        call search('^\d\+ .* \d\+$')
    endfor
endfunc
func! PrevChapter() range
    for i in range(v:count1)
        call search('^\d\+ .* \d\+$','b')
    endfor
endfunc

" https://vi.stackexchange.com/a/1958/10254
command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

" func! Capture(command)
"     redir =>output
"     silent exec a:command
"     redir END
"     return output
" endfunc!

func! Capture(excmd) abort  " from tpope's scriptease.vim
  try
    redir => out
    exe 'silent! '.a:excmd
    " silent 'exe! '.a:excmd
  finally
    redir END
  endtry
  return out
endfunc

func! PutAfterCapture(command)
    if a:command =~ '^\s*$'
        return
    endif
    let oldpos = getpos('.')
    silent! let result = Capture(a:command)
    " :put =Capture(a:command)     " use '=' register, not to clutter register.
    " a:command may change cursor position
    call setpos('.', oldpos)
    put=result
    " put change cursor position
    call setpos('.', oldpos)
endfunc!

func! ExternalCommandCapture(command)
endfunc!

" usage, 'Icapture ls'
command! -bar -nargs=+ Icapture call PutAfterCapture(<q-args>)
" TODO not work, usage, 'Capture ls|copen'
" see ~/.vim/bundle/vim-scriptease/plugin/scriptease.vim    -- ':copen' then search 'ease' then 'gf' then search 'copen'
" command! -bar -nargs=+ Capture call Capture(<q-args>)

" emacs <C-l> equivalent, similar to 'zz' then 'zt' then 'zb'
" todo

func! IcecreamInitialize()
python3 << EOF
class StrawberryIcecream:
    def __call__(self):
        print('EAT ME')
obj = StrawberryIcecream()
obj()
EOF
endfunc

" ~/.vim/bundle/vim-colors-solarized/autoload/togglebg.vim
" func! s:TogBG()
func! TogBG()
    let &background = ( &background == "dark"? "light" : "dark" )
    if exists("g:colors_name")
        exe "colorscheme " . g:colors_name
    endif
endfunc

command GetRunningData py3f ~/notes/task/vim/running.py

" https://vi.stackexchange.com/questions/7734/how-to-save-and-restore-a-mapping
"{{{
fu! Save_mappings(keys, mode, global) abort
    let mappings = {}

    if a:global
        for l:key in a:keys
            let buf_local_map = maparg(l:key, a:mode, 0, 1)

            sil! exe a:mode.'unmap <buffer> '.l:key

            let map_info        = maparg(l:key, a:mode, 0, 1)
            let mappings[l:key] = !empty(map_info)
                                \     ? map_info
                                \     : {
                                        \ 'unmapped' : 1,
                                        \ 'buffer'   : 0,
                                        \ 'lhs'      : l:key,
                                        \ 'mode'     : a:mode,
                                        \ }

            call Restore_mappings({l:key : buf_local_map})
        endfor

    else
        for l:key in a:keys
            let map_info        = maparg(l:key, a:mode, 0, 1)
            let mappings[l:key] = !empty(map_info)
                                \     ? map_info
                                \     : {
                                        \ 'unmapped' : 1,
                                        \ 'buffer'   : 1,
                                        \ 'lhs'      : l:key,
                                        \ 'mode'     : a:mode,
                                        \ }
        endfor
    endif

    return mappings
endfu

" ... and this one to restore them:

fu! Restore_mappings(mappings) abort

    for mapping in values(a:mappings)
        if !has_key(mapping, 'unmapped') && !empty(mapping)
            exe     mapping.mode
               \ . (mapping.noremap ? 'noremap   ' : 'map ')
               \ . (mapping.buffer  ? ' <buffer> ' : '')
               \ . (mapping.expr    ? ' <expr>   ' : '')
               \ . (mapping.nowait  ? ' <nowait> ' : '')
               \ . (mapping.silent  ? ' <silent> ' : '')
               \ .  mapping.lhs
               \ . ' '
               \ . substitute(mapping.rhs, '<SID>', '<SNR>'.mapping.sid.'_', 'g')

        elseif has_key(mapping, 'unmapped')
            sil! exe mapping.mode.'unmap '
                                \ .(mapping.buffer ? ' <buffer> ' : '')
                                \ . mapping.lhs
        endif
    endfor

endfu
" }}}

" .utility.vim
" .vimrc
