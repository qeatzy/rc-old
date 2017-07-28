function! s:is_search() abort
  return getcmdtype() =~# '[/\?]'
endfunction


if stridx(&rtp, '/is.vim') == -1
    cnoremap <C-k> <Up>
    cnoremap <C-j> <Down>
else
    cnoremap <expr> <C-k> (getcmdtype() =~# '[/\?]' && getcmdline() != '' ) ? is#scroll(1) : '<Up>'
    cnoremap <expr> <C-j> (getcmdtype() =~# '[/\?]' && getcmdline() != '' ) ? is#scroll(0) : '<Down>'
endif
