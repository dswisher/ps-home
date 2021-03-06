"
"  Doug's VIM initialization file
"

" Vundle setup and load plugins
"   https://github.com/gmarik/Vundle.vim
set nocompatible        " don't try to be compatible with vi
filetype off

set rtp+=$HOME/.vim/bundle/Vundle.vim/
call vundle#begin()

" Core plugins
Plugin 'gmarik/Vundle.vim'          " package management

" Main plugins
Plugin 'scrooloose/nerdtree'        " file explorer
Plugin 'jlanzarotta/bufexplorer'    " better buffer list
Plugin 'scrooloose/syntastic'

" Experimental
Plugin 'PProvost/vim-ps1.git'       " powershell support
" Plugin 'posva/vim-vue'              " vuejs syntax highlighting
Plugin 'ctrlpvim/ctrlp.vim'         " fuzzy file finder
" Plugin 'tpope/vim-surround'         " surround
" Plugin 'tpope/vim-repeat'           " repeat support for surround and other plugins
" Plugin 'tpope/vim-commentary'       " support for commenting things out
" Plugin 'mileszs/ack.vim'            " search using Ack
" Plugin 'ludovicchabant/vim-gutentags'       " better tags support?
Plugin 'ConradIrwin/vim-bracketed-paste'    " automagically set paste when pasting
" Plugin 'maxbrunsfeld/vim-yankstack'         " paste older text
" Plugin 'davidhalter/jedi-vim'               " Python code completion, via Jedi

" Remapping the tab key seems to mess me up more often than it helps
" Plugin 'ervandew/supertab'          " tab completion

" airline does not work right in WSL
" Plugin 'vim-airline/vim-airline'    " fancy status bar
" Plugin 'vim-airline/vim-airline-themes'

" Language-specific
" Plugin 'fatih/vim-go'           " Support for go

" Python
" Always folds everything up on file open; ick.
" Plugin 'tmhedberg/SimpylFold'       " folding


call vundle#end()            " required
filetype plugin indent on    " required

syntax on               " syntax coloring is very cool...turn it on...
" syntax sync fromstart
" colorscheme default
colorscheme slate

set autoindent          " always set autoindenting on
set expandtab           " spaces instead of tabs
set hidden              " keep hidden buffers
set incsearch           " show search progress
set laststatus=2        " always show a status line
set makeprg=xbuild      " doing mono development by default
set ruler               " show line,column in status line
set scrolloff=1         " keep a couple of lines above/below cursor
set shiftround          " round indent when using > and <
set shiftwidth=4        " when indenting, use 4 spaces
set shortmess=a         " abbreviate messages to get rid of [hit return] prompts
set showcmd             " show partial commands in status line
set tabstop=4           " work like the rest of marketwatch
set viminfo='50,/10     " save last ten find commands in viminfo file
set visualbell          " flash screen instead of beeping
set nowrap              " don't wrap lines
set wrapscan            " wrap searches around end of file
" set wildmenu

" set t_BE=               " disable bracketed paste in iterm2

set number              " show line numbers
set relativenumber      " ...and make 'em relative

set statusline =
" Buffer number
set statusline +=[%n] 
" File description
set statusline +=\ %f\ %h%m%r%w
" Name of the current branch (needs fugitive.vim)
" set statusline +=\ %{fugitive#statusline()}
" Date of the last time the file was saved
" set statusline +=\ %{strftime(\"[%d/%m/%y\ %T]\",getftime(expand(\"%:p\")))} 
" Total number of lines in the file
set statusline +=%=%-10L
" Line, column and percentage
set statusline +=%=%-14.(%l,%c%V%)
" Filetype
set statusline +=\ %y

" Enable folding
" set foldmethod=indent
" set foldlevel=99

" set up tabs in shell files
autocmd FileType sh setlocal shiftwidth=2 tabstop=2

" do not automatically add comments to new lines
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set tags=./tags;/		" look in current and all parent directories for tags file

let mapleader=","

" - - - - BufExplorer Setup
let g:bufExplorerDisableDefaultKeyMapping=1
nmap <leader>b :BufExplorerHorizontalSplit<CR>

" - - - - NerdTree Setup
"map <C-n> :NERDTreeToggle<CR>
nmap <leader>t :NERDTreeToggle<CR>
nmap <leader>f :NERDTreeFind<CR>

let NERDTreeIgnore=['\.pyc$']   " ignore files in NERDTree

" - - - - jedi-vim Setup
" let g:jedi#popup_on_dot = 0

" - - - - CtrlP Setup
nmap <leader>p :CtrlPMRU<CR>
"let g:ctrlp_custom_ignore = {
"  \ 'dir':  '\v[\/](\.(git|hg|svn)|(obj|bin))$',
"  \ 'file': '\v\.(exe|so|dll)$'
"  \ }

" - - - - Syntastic setup
let g:syntastic_enable_signs = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_highlighting = 0
let g:syntastic_always_populate_loc_list = 1    " can use :lnext and :lprev to move between errors

let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_post_args="--max-line-length=175"

let g:syntastic_html_checkers=['']
let g:syntastic_asm_compiler=''

nmap <leader>sc :SyntasticReset<CR>
nmap <leader>sn :lnext<CR>
nmap <leader>ss :SyntasticCheck<CR>

" - - - - Yankstack mappings
" nmap <leader>p <Plug>yankstack_substitute_older_paste
" nmap <leader>P <Plug>yankstack_substitute_newer_paste

