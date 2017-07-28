" " let g:_themes = ['Dracula', 'Ura', 'Vaughn']
" let g:theme_client = 'python3 /home/zyq3e/notes/swo/rc/color/theme_client.py '
" let s = system(g:theme_client . ' list')
" let g:_themes = split(s,'\n')[1:]
"
" func! Increment_theme_ind(...) abort
"     let lst = get(a:000, '1', g:_themes)
"     if get(g:, '_ind_themes', -1) < 0 || g:_ind_themes >= len(lst)
"         let g:_ind_themes = 0
"     endif
"     let name = lst[g:_ind_themes]
"     let g:_ind_themes += 1
"     return name
" endfunc
"
" func! Decrement_theme_ind(...) abort
"     let lst = get(a:000, '1', g:_themes)
"     if get(g:, '_ind_themes', -1) < 0 || g:_ind_themes >= len(lst)
"         let g:_ind_themes = len(lst) - 1
"     endif
"     let name = lst[g:_ind_themes]
"     let g:_ind_themes += -1
"     return name
" endfunc
"
" func! Set_theme_ind(ind, ...) abort
"     let lst = get(a:000, '1', g:_themes)
"     if a:ind >= 0 && a:ind < len(lst)
"         let g:_ind_themes = a:ind
"     endif
"     return g:_ind_themes
" endfunc
"
" " echo Decrement_theme_ind()
" " echo Increment_theme_ind()
"
" func! Set_theme(name)
"     sil exec '!' . g:theme_client . ' set ' . a:name
"     redraw!
"     echo a:name
" endfunc
"
" func! Toggle_loop_theme()
"     if get(g:, '_Toggle_loop_theme', v:false) == v:false
"         let g:_Toggle_loop_theme = v:true
"         echo "Toggle_loop_theme true"
"         nnoremap j :<C-u>call Set_theme(Increment_theme_ind())<CR>
"         nnoremap k :<C-u>call Set_theme(Decrement_theme_ind())<CR>
"         let g:__saved_mapping =  Save_mappings(['s'],'n',1)
"         nnoremap s :<C-u>call Show_theme(v:count)<CR>
"     else
"         echo "Toggle_loop_theme false"
"         let g:_Toggle_loop_theme = v:false
"         nunmap j
"         nunmap k
"         call Restore_mappings(g:__saved_mapping)
"         " nunmap s
"     endif
" endfunc

if !exists('g:d_loop_theme')
    let g:d_loop_theme = {}
endif
func! Loop_themes(dir, ...)
    if !has_key(g:d_loop_theme, a:dir)
        let fns = system('ls --color=never --no-group ' . a:dir . '/*')
        let fns = split(fns, '\n')
        let fns = filter(fns, {key, val -> ! (val =~ "base16" && val !~ "256")})
        let x = [-1, fns]
        let g:d_loop_theme[a:dir] = x
    endif
    let x = g:d_loop_theme[a:dir]
    let length = len(x[1])
    if x[0] >= length || x[0] < 0
        let x[0] = (x[0] + length) % length
    endif
    " return
    " echo fns
    " echo len(fns) . fns[0]
    " for fn in fns[3:5]
    let n = get(a:, 1, length)
    if n == 0
        exec 'sil! !cat ' . x[1][x[0]] . '&'
        redraw!
        return
    endif
    let step = n>0? 1 : length-1
    let n = min([abs(n), length])
    let fns = x[1]
    for i in range(n)
        let x[0] = (x[0] + step) % length
        let fn = fns[x[0]]
        " sil! exec '!cat ' . fn
        exec 'sil! !cat ' . fn . '&'
        redraw!
        echo x[0] x[1][x[0]]
        sleep 200m
    endfor
endfunc
" echo 'fin'

func! Show_theme(count)
    let x = g:d_loop_theme[g:color_dir]
    let ind = x[0]
    let name = x[1]
    " echo len(name) a:count ind
    if a:count == 0
        echo ind name[ind]
    elseif a:count > len(name)
        echo "last" name[-1] len(name) "total" 
    else
        let x[0] = a:count
        " echo x[0] name[x[0]]
        call Loop_themes(g:color_dir,0)
    endif
endfunc

" if len($TMUX) | echo 'tmux' | else | echo 'no tmux'| endif
" echo $TMUX
" echo len($TMUX)
" echo $HOME
let g:color_dir = '~/.colors/' . (len($TMUX) ? 'tmux' : '') . 'persist'
" let g:color_dir = $HOME . '/.colors/' . (len($TMUX) ? 'tmux' : '') . 'persist'
" echo g:color_dir
let g:_save_timeout = [&timeout, &ttimeout]
func! Toggle_mode_loop_theme()
    " echo g:_b_Toggle_mode_loop_theme
    if !get(g:, '_b_Toggle_mode_loop_theme', 0)
        echo 'Toggle_mode_loop_theme on'
        let g:_b_Toggle_mode_loop_theme = 1
        nn  <expr> j Loop_themes(g:color_dir,1)
        nn  <expr> k Loop_themes(g:color_dir,-1)
        " let g:_save_timeout = [&timeout, &ttimeout]
        " set notimeout nottimeout
        nn f :<C-u>call Show_theme(v:count)<CR>
        " noremap r <C-c>
        " lnoremap r <C-c>
        let g:__saved_mapping =  Save_mappings(['s','S'],'n',1)
        nn  s :<C-u>call Loop_themes(g:color_dir)<CR>
        nn  S :<C-u>call Loop_themes(g:color_dir,-99999)<CR>
    else
        echo 'Toggle_mode_loop_theme off'
        let g:_b_Toggle_mode_loop_theme = 0
        " let &timeout = g:_save_timeout[0]
        " let &ttimeout = g:_save_timeout[1]
        " unmap r
        " lunmap r
        nunmap f
        nunmap j
        nunmap k
        call Restore_mappings(g:__saved_mapping)
    endif
endfunc
nn <f8> :<C-u>call Toggle_mode_loop_theme()<CR>
" echo 'fin'
"
" call Loop_themes(g:color_dir)
" call Loop_themes(g:color_dir,3)
" call Loop_themes(g:color_dir,-3)
" echo g:d_loop_theme[g:color_dir][0]
" nn  <expr> j Loop_themes(g:color_dir,1)
" nn  <expr> k Loop_themes(g:color_dir,-1)
" nunmap <buffer> j
" nn <buffer> <expr> j Loop_themes(g:color_dir,1)
" nn <buffer> <expr> k Loop_themes(g:color_dir,-1)
" nunmap <buffer> j
" nunmap <buffer> k
" nunmap <buffer> s
"
" nnoremap <F4> :<C-u>call Toggle_loop_theme()<CR>
" " nnoremap <F4> :<C-u>echo 3333<CR>
