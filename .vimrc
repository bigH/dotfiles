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

" Ignore case in search
set ignorecase

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

" Remember commands
set history=1000

" Indent wrapped lines up to the same level
if exists('&breakindent')
  set breakindent
endif

" Use the mouse
set mouse=a

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

" backspace should eat all
set backspace=indent,eol,start

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

" Show relative numbers on the left side
set relativenumber

" Don't allow cursor to be at edges
set scrolloff=1
set sidescrolloff=5

" Delete comment character when joining lines
set formatoptions+=j

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

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

"}}}


"{{{ Line Number and Paste Toggle

let paste_mode = 0 " 0 = relative, 1 = paste, 2 = absolute

func! Paste_on_off()
   if g:paste_mode == 0
      sign unplace *
      set paste
      set nonumber
      set norelativenumber
      let g:paste_mode = 1
   elseif g:paste_mode == 1
      set nopaste
      set number
      set norelativenumber
      let g:paste_mode = 2
   else
      set nopaste
      set nonumber
      set relativenumber
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

" Next Tab - unfocus NERDTree
nmap <silent> <Left> :wincmd l<CR>:tabprevious<CR>
imap <silent> <Left> <Esc>:wincmd l<CR>:tabprevious<CR>
nmap <silent> H :wincmd l<CR>:tabprevious<CR>

" Previous Tab - unfocus NERDTree
nmap <silent> <Right> :wincmd l<CR>:tabnext<CR>
imap <silent> <Right> <Esc>:wincmd l<CR>:tabnext<CR>
nmap <silent> L :wincmd l<CR>:tabnext<CR>

" First Tab - unfocus NERDTree
nmap <silent> <Up> :wincmd l<CR>:tabfirst<CR>
imap <silent> <Up> <Esc>:wincmd l<CR>:tabfirst<CR>

" Previous Tab - unfocus NERDTree
nmap <silent> <Down> :wincmd l<CR>:tablast<CR>
imap <silent> <Down> <Esc>:wincmd l<CR>:tablast<CR>

" Move Tab Left
nmap <silent> <S-Left> :tabm -1<CR>
imap <silent> <S-Left> <Esc>:tabm -1<CR>

" Move Tab Right
nmap <silent> <S-Right> :tabm +1<CR>
imap <silent> <S-Right> <Esc>:tabm +1<CR>

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
"" This is totally awesome - remap jj to escape in insert mode.  You'll never type jj anyway, so it's great!
" inoremap jj <Esc>
" inoremap <Esc> <NOP>

" Disable Ex-Mode and map Q to quit
map Q :q<CR>

" Avoid deleting text while inserting that cannot be recovered
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

"}}}


"{{{ Commands

" Commonly mispelled
command! Q  q
command! Qa  qa
command! QA  qa
command! W  w
command! E  e
command! Wq wq
command! WQ wq
command! WQA wqa
command! WQa wqa
command! Wqa wqa

" Write read-only file with sudo
command! WS w !sudo tee %

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
Plugin 'altercation/vim-colors-solarized'
Plugin 'kana/vim-surround'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'airblade/vim-rooter'
Plugin 'scrooloose/nerdcommenter'
Plugin 'w0rp/ale'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'tmhedberg/matchit'
Plugin 'kana/vim-textobj-user'
Plugin 'nelstrom/vim-textobj-rubyblock'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-easytags'
Plugin 'majutsushi/tagbar'

" Plugin 'vim-ruby/vim-ruby'
" Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'

call vundle#end()

" Turn filetype back on after Vundle
filetype on
filetype plugin on

"}}}


"{{{ Plugin Configurations

" -- vim-colors-solarized --

" Use correct vim colors in solarized
colorscheme solarized

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

" -- ale --

" Execution configs
let g:ale_linters = {}
let g:ale_linters['ruby'] = ['rubocop']
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_linters['javascript'] = ['eslint', 'flow']

" Don't lint while typing
let g:ale_lint_on_text_changed = 'never'

" Show the full list of lint errors
let g:ale_open_list = 1

" -- nerd-tree --

" Set it to not show `? for help`
let NERDTreeMinimalUI = 1

" -- airline --
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffers_label = ''
let g:airline#extensions#tabline#tabs_label = ''

" -- easytags --

" Put tags in these directories
set tags=./tags;,~/.vimtags

" Re-tag file after these events
let g:easytags_events = ['BufReadPost', 'BufWritePost']

" Update tags file asyncronously
let g:easytags_async = 1


" -- tagbar --

" -- IDE Feel --

" F1 opens NERDTree
nmap <silent> <F1> :NERDTreeFind<CR>
imap <silent> <F1> <Esc>:NERDTreeFind<CR>a

" F2 opens Tagbar
nmap <silent> <F2> :TagbarOpen<CR>
imap <silent> <F2> <Esc>:TagbarOpen<CR>a

" F3 focus rotation
nmap <silent> <F3> :wincmd w<CR>
imap <silent> <F3> <Esc>:wincmd w<CR>a

" F4 closes both
nmap <silent> <F4> :NERDTreeClose<CR>:TagbarClose<CR>
imap <silent> <F4> <Esc>:NERDTreeClose<CR>:TagbarClose<CR>a

" -- vim-textobj-rubyblock --
runtime macros/matchit.vim

"}}}



