"=========================================================
" Core
"=========================================================
set nocompatible
set background=light
syntax on
colorscheme light_custom

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
        " Clear the message after 2 seconds so it doesn't linger
        defer timer_start(2000, {-> execute('echo ""')})
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

nnoremap <leader>e <cmd>Explore<CR>
nnoremap <leader>` <cmd>bel term<CR>
nnoremap <leader>b :ls<CR>:b 
nnoremap <leader>g <cmd>Rg<CR>
nnoremap <leader>f <cmd>FZF<CR>
nnoremap <C-p> <cmd>Files<CR>

nnoremap <leader>m <cmd>make<CR>
nnoremap <leader>r <cmd>!./%<<CR>

" Quickfix
nnoremap <leader>n <cmd>cnext<CR>
nnoremap <leader>N <cmd>cprev<CR>
nnoremap <leader>q <cmd>copen<CR>
nnoremap <leader>c <cmd>cclose<CR>

" Tags
nnoremap <leader>jd <C-]>
nnoremap <leader>jb <C-t>

"=========================================================
" ALE
"=========================================================
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
nnoremap <leader>d :ALEDetail<CR>
nnoremap <leader>l :lopen<CR>

nnoremap <S-k> <cmd>ALEHover<CR>
nnoremap <leader>gd <cmd>ALEGoToDefinition<CR>
nnoremap <leader>gi <cmd>ALEGoToImplementation<CR>
nnoremap <leader>gr <cmd>ALEFindReferences<CR>
nnoremap <leader>ca <cmd>ALECodeAction<CR>

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

