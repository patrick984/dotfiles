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

let c_functions = 1

set wildignore+=*.o,*.obj,*.a,*.so,*.dylib,*.class
set wildignore+=*.pyc,*.pyo,*.gem,*.egg
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store,*/.cache/*
set wildignore+=*/node_modules/*,*/bower_components/*
set wildignore+=*.swp,*.swo,*.tmp,*~,*.un~

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

let g:netrw_winsize = 30
autocmd FileType netrw wincmd L

nmap <silent> <leader>e <cmd>Lex!<CR>

" Use ctrl-[hjkl] to select the active split.
nmap <silent> <leader>h :wincmd h<CR>
nmap <silent> <leader>j :wincmd j<CR>
nmap <silent> <leader>k :wincmd k<CR>
nmap <silent> <leader>l :wincmd l<CR>

" Use g[hjkl] to move splits around.
nnoremap <leader><left> <C-W><C-H>
nnoremap <leader><down> <C-W><C-J>
nnoremap <leader><up> <C-W><C-K>
nnoremap <leader><right> <C-W><C-L>

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
set noautocomplete
set complete=o
set completeopt=menuone,noinsert,noselect
set completeopt+=fuzzy

inoremap <C-Space> <C-x><C-o>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

"=========================================================
" LSP Specific Smart Triggers
"=========================================================

" 1. Typing '.' inserts '.' then instantly checks for LSP members
inoremap <expr> . SmartDotTrigger()

function! SmartDotTrigger()
    " If inside a comment or string syntax block, do not trigger
    let l:syntax_group = synIDattr(synID(line('.'), col('.') - 1, 1), 'name')
    if l:syntax_group =~? 'comment\|string'
        return '.'
    endif
    
    " Safely feed Ctrl-x followed by Ctrl-o via a brief 10ms timer
    call timer_start(10, {-> feedkeys("\<C-x>\<C-o>", 'm')})
    return '.'
endfunction


" 2. Typing '>' inserts '>' and checks if it completes an arrow '->'
inoremap <expr> > SmartArrowTrigger()

function! SmartArrowTrigger()
    " Get text from start of line up to the cursor
    let l:line_text = strpart(getline('.'), 0, col('.') - 1)
    
    " Check if the character directly behind the cursor is a hyphen
    if l:line_text =~ '-$'
        " Safely feed Ctrl-x followed by Ctrl-o via a brief 10ms timer
        call timer_start(10, {-> feedkeys("\<C-x>\<C-o>", 'm')})
    endif
    return '>'
endfunction

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

nnoremap Y y$

nnoremap <silent> <C-L> :nohlsearch<CR><C-L>

nnoremap <leader>` <cmd>bel term<CR>
nnoremap <leader>b :ls<CR>:b
nnoremap <leader>g <cmd>call ProjectGrep()<CR>
nnoremap <leader>f <cmd>call FindFile()<CR>
nnoremap <C-p> <cmd>call FindFile()<CR>

nnoremap <leader>m <cmd>make<CR>
nnoremap <leader>r <cmd>!./%<<CR>

" Quickfix
nnoremap <leader>n <cmd>cnext<CR>
nnoremap <leader>N <cmd>cprev<CR>
nnoremap <leader>q <cmd>copen<CR>
nnoremap <leader>c <cmd>cclose<CR>

" Visual Surround
xmap " S"
xmap ' S'
xmap ( S)
xmap [ S]
xmap { S}

" Disable bad maps
nnoremap Q <nop>

" Define a function to toggle the location list
function! ToggleLocationList()
    " Check if any window in the current tab is a location list window
    let l:loc_open = filter(getwininfo(), 'v:val.loclist && v:val.tabnr == tabpagenr()')
    if empty(l:loc_open)
        lopen
    else
        lclose
    endif
endfunction

nnoremap <silent> <leader>l :call ToggleLocationList()<CR>

"=========================================================
" ALE
"=========================================================
let g:ale_enabled = 0
let g:ale_disable_lsp = 1

let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 300

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
nnoremap <leader>d :OptionalCommand('ALEDetail')<CR>

"=========================================================
" LSP
""=========================================================

let lspOpts = #{
      \ aleSupport: v:true,
      \ autoHighlightDiags: v:true,
      \ autoPopulateDiags: v:true,
      \ omniComplete: v:true,
      \ autoComplete: v:false,
      \ completionTextEdit: v:true,
      \ echoSignature: v:true,
      \ hoverInPreview: v:true,
      \ semanticHighlight: v:true,
      \ showDiagInPopup: v:true,
      \ snippetSupport: v:false,
      \ }
autocmd User LspSetup call LspOptionsSet(lspOpts)

let csharp_bin = exepath(expand('~/.dotnet/tools/roslyn-language-server'))
let rustanalyzer_bin = exepath(expand('~/.rustup/toolchains/stable-aarch64-apple-darwin/bin/rust-analyzer'))

let lspServers = [#{
      \ name: 'clangd',
      \ filetype: ['c', 'cpp'],
      \ path: 'clangd',
      \ args: ['--background-index'],
      \ },
      \
      \ #{
      \ name: 'roslyn-ls',
      \ filetype: ['cs'],
      \ path: csharp_bin,
      \ args: ['--stdio', '--autoLoadProjects'],
      \ },
      \
      \ #{
      \ name: 'pyright',
      \ filetype: ['python'],
      \ path: 'pyright-langserver',
      \ args: ['--stdio'],
      \ },
      \
      \ #{
      \ name: 'rustlang',
      \ filetype: ['rust'],
      \ path: rustanalyzer_bin,
      \ args: [],
      \ syncInit: v:true
      \ }
      \ ]
autocmd User LspSetup call LspAddServer(lspServers)

nnoremap gd <cmd>call OptionalCommand('LspGotoDefinition')<CR>
nnoremap gD <cmd>call OptionalCommand('LspGotoDeclaration')<CR>
nnoremap grr <cmd>call OptionalCommand('LspShowReferences')<CR>
nnoremap gri <cmd>call OptionalCommand('LspGotoImpl')<CR>
nnoremap K  <cmd>call OptionalCommand('LspHover')<CR>

nnoremap grn <cmd>call OptionalCommand('LspRename')<CR>
nnoremap gra <cmd>call OptionalCommand('LspCodeAction')<CR>

nnoremap [d <cmd>call OptionalCommand('LspDiagPrev')<CR>
nnoremap ]d <cmd>call OptionalCommand('LspDiagNext')<CR>

nnoremap <leader>cf <cmd>call OptionalCommand('LspFormat')<CR>
nnoremap <leader>th <cmd>call OptionalCommand('LspInlayHints toggle')<CR>
nnoremap <leader>cc <cmd>call OptionalCommand('LspSwitchSourceHeader')<CR>
nnoremap <Leader>x :cclose<Bar>lclose<Bar>pclose<CR>

let g:fzf_vim = {}
let g:fzf_vim.preview_window = ['up,50%', 'ctrl-/']

"=========================================================
" Optional plugin helpers
"=========================================================
function! FindFile()
    if exists(':Files') == 2
        Files
    elseif exists(':FZF') == 2
        FZF
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

function! OptionalCommand(command, ...)
    " Extract just the base command name to check if it exists
    let l:base_cmd = split(a:command, ' ')[0]
    
    if exists(':' . l:base_cmd) == 2
        " Combine the command and any extra arguments passed to the function
        let l:full_cmd = a:command
        if a:0 > 0
            let l:full_cmd .= ' ' . join(a:000, ' ')
        endif
        
        execute l:full_cmd
    else
        echo l:base_cmd . ' is unavailable'
    endif
endfunction

nnoremap <leader>s :call OptionalCommand('Git')<CR>

"=========================================================
" Plugins
"=========================================================
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'yegappan/lsp'
Plug 'dense-analysis/ale'
    
call plug#end()

endif
