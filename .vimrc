" =============================================================================
" Tim's Vim Configuration
" =============================================================================

" --- Plugin Manager (vim-plug) ---
" Auto-install vim-plug if missing
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs '
    \ .'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" --- Terraform / HCL ---
Plug 'hashivim/vim-terraform'        " Syntax, :Terraform cmd, fmt on save
Plug 'vim-syntastic/syntastic'       " Syntax checking (works with terraform)

call plug#end()

" --- Terraform Settings ---
let g:terraform_align = 1             " Align settings in .tf files
let g:terraform_fmt_on_save = 1       " Auto-run terraform fmt on save
let g:terraform_fold_sections = 0     " Don't fold terraform sections

" --- General Settings ---
set nocompatible              " Use Vim defaults (not Vi)
set encoding=utf-8            " UTF-8 encoding
set fileencoding=utf-8
set history=1000              " Store lots of command history
set undolevels=1000           " Lots of undo
set autoread                  " Reload files changed outside vim
set hidden                    " Allow buffers in background without saving
set backspace=indent,eol,start " Backspace works as expected

" --- UI / Display ---
set number                    " Show line numbers
set relativenumber            " Relative line numbers for easy jumping
set cursorline                " Highlight current line
set showmatch                 " Highlight matching brackets
set showcmd                   " Show incomplete commands
set showmode                  " Show current mode
set laststatus=2              " Always show status line
set ruler                     " Show cursor position
set wildmenu                  " Enhanced command-line completion
set wildmode=list:longest,full
set scrolloff=8               " Keep 8 lines above/below cursor
set sidescrolloff=5
set signcolumn=yes            " Always show sign column

" --- Syntax & Colors ---
syntax enable                 " Enable syntax highlighting
filetype plugin indent on     " Enable filetype detection, plugins, indent
set background=dark           " Dark background
set termguicolors             " True color support (if terminal supports it)

" --- Search ---
set incsearch                 " Incremental search
set hlsearch                  " Highlight search results
set ignorecase                " Case-insensitive search...
set smartcase                 " ...unless query has uppercase

" Clear search highlighting with <leader><space>
nnoremap <leader><space> :nohlsearch<CR>

" --- Indentation ---
set autoindent                " Copy indent from current line
set smartindent               " Smart auto-indenting
set expandtab                 " Use spaces instead of tabs
set tabstop=4                 " Tab = 4 spaces
set shiftwidth=4              " Indent = 4 spaces
set softtabstop=4             " Backspace through spaces like tabs

" --- Wrapping ---
set wrap                      " Soft wrap long lines
set linebreak                 " Wrap at word boundaries
set textwidth=0               " Don't hard-wrap text

" --- Splits ---
set splitbelow                " Open horizontal splits below
set splitright                " Open vertical splits to the right

" Easier split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" --- Files & Backup ---
set nobackup                  " Don't create backup files
set nowritebackup
set noswapfile                " Don't create swap files
set undofile                  " Persistent undo
set undodir=~/.vim/undodir    " Undo file directory

" --- Clipboard ---
set clipboard=unnamedplus     " Use system clipboard

" --- Netrw (built-in file explorer) ---
let g:netrw_banner = 0        " Hide banner
let g:netrw_liststyle = 3     " Tree view
let g:netrw_browse_split = 4  " Open in previous window
let g:netrw_winsize = 25      " 25% width

" --- Quality of Life ---
" Quickly edit/source vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Move lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Keep cursor centered when jumping
nnoremap n nzzzv
nnoremap N Nzzzv

" Don't lose selection when indenting
vnoremap < <gv
vnoremap > >gv
