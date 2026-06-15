" Clear existing highlights
highlight clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "light_custom"

" =========================
" Base UI
" =========================
set background=light

highlight Title         guifg=#7c3c00 guibg=NONE    gui=bold   ctermfg=94   ctermbg=NONE cterm=bold
highlight Normal        guifg=#000000 guibg=#fffff5 gui=NONE   ctermfg=16   ctermbg=231  cterm=NONE
highlight NormalAlt     guifg=#000000 guibg=#f6f8fa gui=NONE   ctermfg=16   ctermbg=231  cterm=NONE
highlight CursorLine    guifg=NONE    guibg=#f6f8fa gui=NONE   ctermfg=NONE ctermbg=231  cterm=NONE
highlight CursorColumn  guifg=NONE    guibg=#f6f8fa gui=NONE   ctermfg=NONE ctermbg=231  cterm=NONE
highlight LineNr        guifg=#000000 guibg=NONE    gui=NONE   ctermfg=16   ctermbg=NONE cterm=NONE
highlight CursorLineNr  guifg=#000000 guibg=NONE    gui=NONE   ctermfg=16   ctermbg=NONE cterm=NONE

highlight Visual        guifg=NONE    guibg=#9fdfff gui=NONE   ctermfg=NONE ctermbg=153  cterm=NONE
highlight Search        guifg=NONE    guibg=#7dec97 gui=NONE   ctermfg=NONE ctermbg=120  cterm=NONE
highlight IncSearch     guifg=NONE    guibg=#ffdf5d gui=NONE   ctermfg=NONE ctermbg=221  cterm=NONE
highlight CurSearch     guifg=NONE    guibg=#ffdf5d gui=NONE   ctermfg=NONE ctermbg=221  cterm=NONE

highlight MatchParen    guifg=NONE    guibg=#dc99df gui=NONE   ctermfg=NONE ctermbg=176  cterm=NONE

highlight StatusLine    guifg=#000000 guibg=#ebf5ff gui=bold   ctermfg=16   ctermbg=195  cterm=bold
highlight StatusLineNC  guifg=#000000 guibg=#ebf5ff gui=NONE   ctermfg=16   ctermbg=195  cterm=NONE

highlight VertSplit     guifg=#ebf5ff guibg=#ebf5ff gui=NONE   ctermfg=195  ctermbg=195  cterm=NONE
highlight WinSeparator  guifg=#ebf5ff guibg=#ebf5ff gui=NONE   ctermfg=195  ctermbg=195  cterm=NONE

highlight Pmenu         guifg=#000000 guibg=#eaffea gui=NONE   ctermfg=16   ctermbg=194  cterm=NONE
highlight PmenuSel      guifg=#ffffff guibg=#558855 gui=NONE   ctermfg=231  ctermbg=65   cterm=NONE
highlight PmenuSbar     guibg=#000000 ctermbg=16
highlight PmenuThumb    guibg=#000000 ctermbg=16

highlight Folded        guifg=#000000 guibg=#0366d6 gui=NONE   ctermfg=16   ctermbg=26   cterm=NONE
highlight FoldColumn    guifg=#000000 guibg=NONE    gui=NONE   ctermfg=16   ctermbg=NONE cterm=NONE

highlight SignColumn    guibg=NONE    ctermbg=NONE
highlight ColorColumn   guibg=#eeeeee ctermbg=255

highlight ErrorMsg      guibg=#bb5d5d ctermbg=131
highlight WarningMsg    guifg=#99884c ctermfg=101

" =========================
" Diff / Git gutter
" =========================
highlight DiffAdd       guifg=#ffffff guibg=#558855 gui=NONE   ctermfg=231  ctermbg=65   cterm=NONE
highlight DiffChange    guifg=#ffffff guibg=#4670bb gui=NONE   ctermfg=231  ctermbg=61   cterm=NONE
highlight DiffDelete    guifg=#ffffff guibg=#bb5d5d gui=NONE   ctermfg=231  ctermbg=131  cterm=NONE

" =========================
" Syntax
" =========================
highlight Comment       guifg=#6b7ca8 guibg=NONE    gui=italic ctermfg=67   ctermbg=NONE cterm=italic
highlight String        guifg=#067200 guibg=NONE    gui=NONE   ctermfg=22   ctermbg=NONE cterm=NONE
highlight Character     guifg=#067200 guibg=NONE    gui=NONE   ctermfg=22   ctermbg=NONE cterm=NONE

highlight Number        guifg=#0254b2 guibg=NONE    gui=NONE   ctermfg=25   ctermbg=NONE cterm=NONE
highlight Float         guifg=#0254b2 guibg=NONE    gui=NONE   ctermfg=25   ctermbg=NONE cterm=NONE

highlight Keyword       guifg=#7b0080 guibg=NONE    gui=NONE   ctermfg=90   ctermbg=NONE cterm=NONE
highlight Operator      guifg=#7b0080 guibg=NONE    gui=NONE   ctermfg=90   ctermbg=NONE cterm=NONE
highlight Statement     guifg=#7b0080 guibg=NONE    gui=NONE   ctermfg=90   ctermbg=NONE cterm=NONE
highlight Conditional   guifg=#7b0080 guibg=NONE    gui=NONE   ctermfg=90   ctermbg=NONE cterm=NONE
highlight Repeat        guifg=#7b0080 guibg=NONE    gui=NONE   ctermfg=90   ctermbg=NONE cterm=NONE

highlight Function      guifg=#102c8a guibg=NONE    gui=NONE   ctermfg=18   ctermbg=NONE cterm=NONE

highlight Type          guifg=#006974 guibg=NONE    gui=NONE   ctermfg=24   ctermbg=NONE cterm=NONE
highlight Identifier    guifg=#000000 guibg=NONE    gui=NONE   ctermfg=16   ctermbg=NONE cterm=NONE

highlight PreProc       guifg=#7c3c00 guibg=NONE    gui=NONE   ctermfg=94   ctermbg=NONE cterm=NONE
highlight Include       guifg=#7c3c00 guibg=NONE    gui=NONE   ctermfg=94   ctermbg=NONE cterm=NONE
highlight Define        guifg=#7c3c00 guibg=NONE    gui=NONE   ctermfg=94   ctermbg=NONE cterm=NONE

highlight Constant      guifg=#7c3c00 guibg=NONE    gui=NONE   ctermfg=94   ctermbg=NONE cterm=NONE
highlight Special       guifg=#7c3c00 guibg=NONE    gui=NONE   ctermfg=94   ctermbg=NONE cterm=NONE

" =========================
" Misc
" =========================
highlight Todo          guifg=#d27400 guibg=#f6f8fa gui=bold   ctermfg=172  ctermbg=231  cterm=bold
highlight NonText       guifg=#000000 ctermfg=16
highlight SpecialKey    guifg=#000000 ctermfg=16

