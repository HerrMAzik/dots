call plug#begin(stdpath('data') . '/plugged')

Plug 'morhetz/gruvbox'
Plug 'lotabout/skim.vim'
Plug 'tpope/vim-commentary'

call plug#end()

colorscheme gruvbox
set number relativenumber
set cursorline
set list listchars+=space:·
set iskeyword+=-
set tabstop=4 shiftwidth=4 smarttab expandtab
set clipboard=unnamedplus
set autoindent smartindent
set hidden
