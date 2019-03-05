set rtp+=~/Development/powerline/bindings/vim
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set nocompatible
filetype indent plugin on
syntax on
set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
set autoindent
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
set guifont=UbuntuMonoDerivativePowerline-Regular:h16
source $VIMRUNTIME/menu.vim
color dracula
