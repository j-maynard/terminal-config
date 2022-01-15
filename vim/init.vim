execute pathogen#infect()
set rtp+=~/Development/powerline/bindings/vim
set rtp+=~/.fzf
set nocompatible
"filetype plugin indent on
filetype indent off
syntax on
set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
"set backspace=indent,eol,start
"set autoindent
set ruler
set laststatus=2
set confirm
"set mouse=a
set cmdheight=2
set number
set colorcolumn=72
set shiftwidth=4
set softtabstop=4
set expandtab
autocmd Filetype rb setlocal tabstop=4
set guifont=UbuntuMonoDerivativePowerline-Regular:h16
source $VIMRUNTIME/menu.vim
color spacecamp 
set updatetime=500
autocmd StdinReadPre * let s:std_in=1
" autocmd vimenter * NERDTree
" autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <C-n> :NERDTreeToggle<CR>
set clipboard=unnamed
map <F8> :setl noai nocin nosi inde=<CR>
let g:airline_powerline_fonts = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
nmap <F6> :NERDTreeToggle<CR>

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ' '
let g:airline_symbols.readonly = ' '
let g:airline_symbols.linenr = '☰ '
let g:airline_symbols.maxlinenr = ' '
let g:airline_symbols.dirty=' '
