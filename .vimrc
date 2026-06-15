"=========================================================
" Core
"=========================================================
" vim.tiny lacks +eval, which normal Vimscript configuration requires.
" Keep tiny usable by skipping this config instead of emitting E319 errors.
silent! if has("eval")

set nocompatible
set background=light
syntax on
let s:vimrc_dir = expand('<sfile>:p:h')
if filereadable(s:vimrc_dir . '/.vim/colors/light_custom.vim')
    execute 'set runtimepath^=' . fnameescape(s:vimrc_dir . '/.vim')
endif

try
    colorscheme light_custom
catch /^Vim\%((\a\+)\)\=:E185/
    echo 'light_custom colorscheme unavailable; using Vim default'
endtry

let mapleader = " "

"=========================================================
" UI / Behavior
"=========================================================
set mouse=a
set hidden
set ruler
set signcolumn=yes
set wildmenu
set wildmode=longest:full,full

set linebreak
set nolist " If set list is on, linebreak can fail

set nomodeline

" Check if the terminal reports true color support via $COLORTERM
" and ensure the feature exists in the current Vim build
if has("termguicolors")
  if ($COLORTERM == 'truecolor' || $COLORTERM == '24bit') && $TERM_PROGRAM != 'Apple_Terminal'
    set termguicolors
  endif
endif


set lazyredraw
set ttyfast

set noerrorbells
set visualbell
set t_vb=
set gcr=a:blinkon0

set history=1000
set updatetime=200

set ttimeout
set ttimeoutlen=30

"=========================================================
" Search
"=========================================================
set incsearch
set hlsearch
set ignorecase
set smartcase

"=========================================================
" Windows / Buffers
"=========================================================
set splitbelow
set splitright

nnoremap <silent> <Tab> <cmd>update<CR><cmd>bnext<CR>
nnoremap <silent> <S-Tab> <cmd>update<CR><cmd>bprevious<CR>

"=========================================================
" Indentation
"=========================================================
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set smarttab

filetype plugin indent on

"=========================================================
" Files / Persistence
"=========================================================
set autoread
set backspace=indent,eol,start
set nrformats-=octal

set undofile
set undodir=~/.vim/undo//
set backup
set backupdir=~/.vim/backup//
set writebackup
set directory=~/.vim/swap//

for d in ['undo', 'backup', 'swap']
    let dir = expand('~/.vim/' . d)
    if !isdirectory(dir)
        call mkdir(dir, 'p')
    endif
endfor

"=========================================================
" Completion
"=========================================================
set completeopt=menuone,noinsert,noselect

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

"=========================================================
" Tags / Paths
"=========================================================
set path+=**
set tags=./tags;,tags;

augroup my_ft
    autocmd!
    autocmd FileType c,cpp setlocal suffixesadd+=.h
augroup END

"=========================================================
" Grep (ripgrep)
"=========================================================
if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif

"=========================================================
" Auto write / reload
"=========================================================
function! BetterAutosave()
    " Only save if: normal buffer, not readonly, has a filename, and is modified
    if &buftype == '' && &readonly == 0 && expand('%') != '' && &modified
        silent update
        " Short visual confirmation in the message area
        echo "Saved: " . expand('%:t')
        if exists('*timer_start')
            call timer_start(2000, {-> execute('echo ""')})
        endif
    endif
endfunction

augroup autosave
    autocmd!
    autocmd BufLeave,FocusLost,WinLeave * call BetterAutosave()
augroup END

"=========================================================
" Keymaps
"=========================================================
nnoremap <C-S-Up> :m -2<CR>==
nnoremap <C-S-Down> :m +1<CR>==
vnoremap <C-S-Up> :m '<-2<CR>gv=gv
vnoremap <C-S-Down> :m '>+1<CR>gv=gv

nnoremap <silent> <C-L> :nohlsearch<CR><C-L>

nnoremap <leader>e :Explore<CR>
nnoremap <leader>` :bel term<CR>
nnoremap <leader>b :ls<CR>:b
nnoremap <leader>g :call ProjectGrep()<CR>
nnoremap <leader>f :call FindFile()<CR>
nnoremap <C-p> :call FindFile()<CR>

nnoremap <leader>m :make<CR>
nnoremap <leader>r :!./%<<CR>

" Quickfix
nnoremap <leader>n :cnext<CR>
nnoremap <leader>N :cprev<CR>
nnoremap <leader>q :copen<CR>
nnoremap <leader>c :cclose<CR>

" Tags
nnoremap <leader>jd <C-]>
nnoremap <leader>jb <C-t>

"=========================================================
" Optional plugin helpers
"=========================================================
function! FindFile()
    if exists(':Files') == 2
        Files
    elseif exists(':FZF') == 2
        FZF
    else
        find
    endif
endfunction

function! ProjectGrep()
    if exists(':Rg') == 2
        Rg
    elseif executable('rg')
        let l:pattern = input('rg: ')
        if !empty(l:pattern)
            execute 'grep! ' . shellescape(l:pattern)
            copen
        endif
    else
        let l:pattern = input('grep: ')
        if !empty(l:pattern)
            execute 'vimgrep /' . escape(l:pattern, '/\') . '/gj **/*'
            copen
        endif
    endif
endfunction

function! OptionalCommand(command)
    if exists(':' . a:command) == 2
        execute a:command
    else
        echo a:command . ' is unavailable'
    endif
endfunction

let g:ale_completion_enabled = 1
let g:ale_completion_auto_popup = 1
let g:ale_completion_delay = 100
let g:ale_completion_max_suggestions = 10

let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 300

let g:ale_fixers = { "python": ["ruff", "ruff_format"] }
let g:ale_fix_on_save = 1

let g:ale_set_signs = 0
let g:ale_set_highlights = 0
let g:ale_virtualtext_cursor = 'disabled'

function! ToggleALEVisibility()
    if exists(':ALEEnableBuffer') != 2
        echo 'ALE is unavailable'
        return
    endif

    let g:ale_visible = !get(g:, 'ale_visible', 0)

    if g:ale_visible
        let g:ale_set_signs = 1
        let g:ale_set_highlights = 1
        let g:ale_virtualtext_cursor = 'all'
        ALEEnableBuffer
        ALELint
    else
        let g:ale_set_signs = 0
        let g:ale_set_highlights = 0
        let g:ale_virtualtext_cursor = 'disabled'
        ALEDisableBuffer
    endif
endfunction

nnoremap <leader>a :call ToggleALEVisibility()<CR>
nnoremap <leader>d :call OptionalCommand('ALEDetail')<CR>
nnoremap <leader>l :lopen<CR>

nnoremap <S-k> :call OptionalCommand('ALEHover')<CR>
nnoremap <leader>gd :call OptionalCommand('ALEGoToDefinition')<CR>
nnoremap <leader>gi :call OptionalCommand('ALEGoToImplementation')<CR>
nnoremap <leader>gr :call OptionalCommand('ALEFindReferences')<CR>
nnoremap <leader>ca :call OptionalCommand('ALECodeAction')<CR>
nnoremap <leader>gs :call OptionalCommand('Git')<CR>

"=========================================================
" Plugins
"=========================================================
"call plug#begin('~/.vim/plugged')

"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"Plug 'junegunn/fzf.vim'
"Plug 'dense-analysis/ale'
"Plug 'airblade/vim-gitgutter'
"Plug 'airblade/vim-rooter'
"Plug 'tpope/vim-surround'
"Plug 'tpope/vim-commentary'
"Plug 'tpope/vim-fugitive'

"call plug#end()

endif
