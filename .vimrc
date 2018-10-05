"{{{ Misc

set fileencodings=utf-8
set encoding=utf-8

" Necesary  for lots of cool vim things
set nocompatible

" This shows what you are typing as a command.  I love this!
set showcmd

" Set syntax highlighting to always on
syntax enable

" 20 tabs max per vim session
set tabpagemax=20

" Who doesn't like autoindent?
set autoindent

" Use english for spellchecking, but don't spellcheck by default
if version >= 700
   set spl=en spell
   set nospell
endif

" Cool tab completion stuff
set wildmenu
set wildmode=list:longest,full

" Show highlighting on search matches
set hlsearch

" Show search matches while typing
set incsearch

" set visualbell, to silence the annoying audible bell
set vb

" When I close a tab, remove the buffer
set nohidden

" Set off the other paren
highlight MatchParen ctermbg=4

" Move backups and temps into home directory
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

"}}}


"{{{ Text Formatting

" show whitespace? list/nolist
set nolist

" 2 space 'tabs'
set tabstop=2

" 2 space indentations
set shiftwidth=2

" expand tabs to spaces
set expandtab

" tabs are dumb
set nosmarttab

" shift to multiples of tabstop
set shiftround

"}}}


"{{{ Highlighting

highlight ExtraWhitespace ctermbg=red guibg=red
au ColorScheme * highlight ExtraWhitespace guibg=red
au BufEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\s\+$/

"}}}


"{{{ UI

" Show the cursor position all the time
set ruler

" Display current mode
set showmode

" Show row numbers on the left side
set number

" Status line gnarliness
set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

"}}}


"{{{ Auto Commands

" Remove any trailing whitespace that is in the file
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" Restore cursor position to where it was before
augroup JumpCursorOnEdit
   au!
   autocmd BufReadPost *
            \ if expand("<afile>:p:h") !=? $TEMP |
            \   if line("'\"") > 1 && line("'\"") <= line("$") |
            \     let JumpCursorOnEdit_foo = line("'\"") |
            \     let b:doopenfold = 1 |
            \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
            \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
            \        let b:doopenfold = 2 |
            \     endif |
            \     exe JumpCursorOnEdit_foo |
            \   endif |
            \ endif
   " Need to postpone using "zv" until after reading the modelines.
   autocmd BufWinEnter *
            \ if exists("b:doopenfold") |
            \   exe "normal zv" |
            \   if(b:doopenfold > 1) |
            \       exe  "+".1 |
            \   endif |
            \   unlet b:doopenfold |
            \ endif
augroup END

"}}}


"{{{ Paste Toggle

let paste_mode = 0 " 0 = normal, 1 = paste

func! Paste_on_off()
   if g:paste_mode == 0
      set paste
      set nonumber
      let g:paste_mode = 1
   else
      set nopaste
      set number
      let g:paste_mode = 0
   endif
   return
endfunc

" Paste Mode!  Dang! <F10>

nnoremap <silent> <F10> :call Paste_on_off()<CR>
set pastetoggle=<F10>

"}}}


"{{{ Key Mappings

" Sane Y
nnoremap <silent> Y y$

" Next Tab -- Mac Specific
nmap <silent> <Left> :tabprevious<CR>
imap <silent> <Left> <Esc>:tabprevious<CR>
nmap <silent> H :tabprevious<CR>

" Previous Tab -- Mac Specific
nmap <silent> <Right> :tabnext<CR>
imap <silent> <Right> <Esc>:tabnext<CR>
nmap <silent> L :tabnext<CR>

" First Tab -- Mac Specific
nmap <silent> <Up> :tabfirst<CR>
imap <silent> <Up> <Esc>:tabfirst<CR>

" Previous Tab -- Mac Specific
nmap <silent> <Down> :tablast<CR>
imap <silent> <Down> <Esc>:tablast<CR>

" Up and down are more logical with g..
nnoremap <silent> k gk
nnoremap <silent> j gj

" Map <Space><Space> to save
nnoremap <silent> <Space><Space> :wa<Enter>

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
map N Nzz
map n nzz

" NOT NEEDED if mapping Caps Lock to Escape
" This is totally awesome - remap jj to escape in insert mode.  You'll never type jj anyway, so it's great!
" inoremap jj <Esc>
" inoremap <Esc> <NOP>

" Disable Ex-Mode
nnoremap Q <Nop>

"}}}


"{{{ Vundle

" Required for vundle
set nocompatible
filetype off

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

" Plugins
Plugin 'kana/vim-surround'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'airblade/vim-rooter'
Plugin 'scrooloose/nerdcommenter'

call vundle#end()

" Turn filetype back on after Vundle
filetype on
filetype plugin on

"}}}


"{{{ Plugin Configurations

" -- fzf --

" Map `K` to FZF file lister (Ctrl-T for new tab)
map K :Files<CR>

" Map `K` to FZF file lister (Ctrl-T for new tab)
map S :GFiles?<CR>

" -- vim-rooter --

" Only respect .git dir
let g:rooter_patterns = ['.git/']

" -- nerdcommenter --

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'


"}}}



