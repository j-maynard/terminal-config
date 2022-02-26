" Load vim-plug
call plug#begin('~/.vim/plugged')

" Get plugins
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'https://github.com/airblade/vim-gitgutter.git'
Plug 'preservim/nerdtree' | Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'arcticicestudio/nord-vim'

" Start plugins
call plug#end()

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
set colorcolumn=80
set shiftwidth=4
set softtabstop=4
set expandtab
autocmd Filetype rb setlocal tabstop=2
source $VIMRUNTIME/menu.vim
"colorscheme nord
set updatetime=500
autocmd StdinReadPre * let s:std_in=1
set hidden

" Setup nerdtree
autocmd vimenter * NERDTree | wincmd p
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nnoremap <C-]> :wincmd p<CR>
set clipboard=unnamed

let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

nmap <F6> :NERDTreeToggle<CR>
map <F8> :setl noai nocin nosi inde=<CR>

"<Leader> Airline Setup below this point
let g:airline_powerline_fonts = 1
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
"let g:airline_theme='wombat'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#whitespace#enabled = 0
let g:airline_section_z = airline#section#create(['windowswap', '%3p%% ', 'linenr', ':%3v'])
set noshowmode

let g:webdevicons_enable = 1
let g:WebDevIconsOS = 'Darwin'

let g:DevIconsEnableFolderPatternMatching = 1
let g:DevIconsEnableFolderExtensionPatternMatching = 1
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols = {} " needed
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {} " needed
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {} " needed

let g:WebDevIconsUnicodeDecorateFileNodesDefaultSymbol = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['md'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['gpg'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['zip'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['pdf'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['doc'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['docx'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['xls'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['xlsx'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['ppt'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['pptx'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['mov'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['heic'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['txt'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['text'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['env'] = ''

let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['Dockerfile'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['dockerfile'] = ''

let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols['Dockerfile'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols['Downloads'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols['Development'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols['Library'] = ''

let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'ﳁ',
                \ 'Staged'    :'',
                \ 'Untracked' :'',
                \ 'Renamed'   :'',
                \ 'Unmerged'  :'ﭥ',
                \ 'Deleted'   :'',
                \ 'Dirty'     :'ﯽ',
                \ 'Ignored'   :'',
                \ 'Clean'     :'',
                \ 'Unknown'   :'',
                \ }
"hi Normal guibg=NONE ctermbg=NONE

lua << EOF
require("bufferline").setup{}
EOF
colorscheme nord

