highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "vanilla"

" hi LineNr               ctermfg=4
hi LineNr               ctermfg=32 cterm=bold
hi CursorLineNr         ctermfg=2
hi Statement            ctermfg=2
hi Comment              ctermfg=4
hi Constant             ctermfg=5
hi PreProc              ctermfg=5

" python
" Statement Identifier Constant 
" plg
" Statement <- Repeat <- pythonRepeat
" Identifier <- Function <- pythonFunction
" vimLineComment -> Comment  :243 OceanicNext
" see SynGroup in vim-colors.txt
