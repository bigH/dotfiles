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
set tabpagemax=50

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

" Save undo-history
set undodir=~/.vim/undodir

" Indent wrapped lines up to the same level
if exists('&breakindent')
  set breakindent
endif

" Use the mouse
set mouse=a

" Put tags in the `.tags` file - `$PROJECT_ROOT/.tags`
" (because of `vim-rooter`)
set tags=.tags;/

" Use a new tab when opening quickfix items
set switchbuf+=usetab,newtab

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

" show tabs if present
set list

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
set scrolloff=5
set sidescrolloff=20

" Delete comment character when joining lines
set formatoptions+=j

" Status line gnarliness
set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

"}}}


"{{{ Auto Commands

" Rehighlight syntax on resize (maybe it works?)
" autocmd VimResized * syntax enable

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


"{{{ Cycle <C-J> and <C-K> functionality
" TODO: create a cycle for <C-J> and <C-K> functionality to do:
" - ale hunks
" - git hunks
" - ruby methods/classes
" - ruby methods/class bodies

" may be un-needed because it uses quickfix window
" nmap <silent> <C-J> <Plug>(ale_next_wrap)
" nmap <silent> <C-K> <Plug>(ale_previous_wrap)

"}}}


"{{{ Line Number and Paste Cycle
" TODO: some commands work on tabs, some don't

let paste_mode = 0 " 0 = relative, 1 = paste, 2 = absolute

func! Paste_on_off()
  if g:paste_mode == 0
    nnoremap <silent> k k
    nnoremap <silent> j j
    sign unplace *
    set paste
    set nonumber
    set norelativenumber
    let g:paste_mode = 1
  elseif g:paste_mode == 1
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    set nopaste
    set number
    set norelativenumber
    let g:paste_mode = 2
  else
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    set nopaste
    set nonumber
    set relativenumber
    let g:paste_mode = 0
  endif
  return
endfunc

" Paste Mode!  Dang! <F10>

nnoremap <silent> <F10> :call Paste_on_off()<CR>

"}}}


"{{{ Key Mappings

" Alt-Enter or <Leader><CR> - insert a new-line here
nnoremap <silent> <CR> i<CR><Esc>
nnoremap <silent> <Leader><CR> i<CR><Esc>

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

" Map <C-\> to `go to definition` in a new tab
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
map <silent> N Nzz
map <silent> n nzz

" Remap Escape to train myself
" inoremap jk <Esc>
" inoremap kj <Esc>
" inoremap <Esc> <NOP>

" Disable Ex-Mode and map Q to quit
map <silent> Q :q<CR>

" Avoid deleting text while inserting that cannot be recovered
inoremap <silent> <c-u> <c-g>u<c-u>
inoremap <silent> <c-w> <c-g>u<c-w>

" 'S' maps to <C-W>
nmap <silent> S <C-W>

" Map Esc in `terminal`
:tnoremap <Esc> <C-\><C-n>

" TODO Map <C-Backspace> to delte previous word - didn't work
" imap <silent> <C-BS> <C-W>

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


"{{{ Custom Plugin Ganks

source ~/.hiren/vim_custom/visual_star.vimrc

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
Plugin 'majutsushi/tagbar'
Plugin 'airblade/vim-gitgutter'
Plugin 'sheerun/vim-polyglot'
Plugin 'morhetz/gruvbox'
Plugin 'elaforge/fast-tags'
Plugin 'neovimhaskell/haskell-vim'
Plugin 'alx741/vim-hindent'
Plugin 'parsonsmatt/intero-neovim'

" Plugin 'vim-ruby/vim-ruby'
" Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'

call vundle#end()

" Turn filetype back on after Vundle
filetype on
filetype plugin on

"}}}


"{{{ Color Scheme Toggle

" choosing dark default
let color_scheme_mode = 0 " 0 = dark, 1 = light
set background=dark

func! ColorSchemeLightDark()
  if g:color_scheme_mode == 0
    set background=light
    let g:color_scheme_mode = 1
  else
    set background=dark
    let g:color_scheme_mode = 0
  endif
  return
endfunc

nnoremap <silent> <F12> :call ColorSchemeLightDark()<CR>
inoremap <silent> <F12> <Esc>:call ColorSchemeLightDark()<CR>a

"}}}


"{{{ Colors

" Use correct vim colors
if !empty(globpath(&rtp, 'colors/gruvbox.vim'))
  colorscheme gruvbox
  let g:airline_theme='gruvbox'
endif

"}}}


"{{{ Plugin Configurations

" -- vim-hindent --

" indent on saving (turn it off in preference of custom prettying)
let g:hindent_on_save = 0

" indent size
let g:hindent_indent_size = 2

" line length
let g:hindent_line_length = 100

" where the hindent command is
let g:hindent_command = "stack exec -- hindent"

" -- haskell-vim --

" Align 'then' two spaces after 'if'
let g:haskell_indent_if = 2

" Indent 'where' block two spaces under previous body
let g:haskell_indent_before_where = 2

" Allow a second case indent style (see haskell-vim README)
let g:haskell_indent_case_alternative = 1

" Only next under 'let' if there's an equals sign
let g:haskell_indent_let_no_in = 0

" to enable highlighting of `forall`
let g:haskell_enable_quantification = 1

" to enable highlighting of `mdo` and `rec`
let g:haskell_enable_recursivedo = 1

" to enable highlighting of `proc`
let g:haskell_enable_arrowsyntax = 1

" to enable highlighting of `pattern`
let g:haskell_enable_pattern_synonyms = 1

" to enable highlighting of type roles
let g:haskell_enable_typeroles = 1

" to enable highlighting of `static`
let g:haskell_enable_static_pointers = 1

" to enable highlighting of backpack keywords
let g:haskell_backpack = 1

" -- stylish-haskell --

" Helper function, called below with mappings
" TODO BufWritePre *.hs HaskellFormat
" TODO Haskell Format should be smart enough to apply stylish-haskell iff a
" `stylish-conf` is present
" TODO does it make sense to apply stylish-haskell on load and hindent on save
"  - then possibly apply stylish-haskell again to make the file editing
"  experience how you want it
function! HaskellFormat(which) abort
  if a:which ==# 'hindent' || a:which ==# 'both'
    :Hindent
  endif
  if a:which ==# 'stylish' || a:which ==# 'both'
    silent! exe 'undojoin'
    silent! exe 'keepjumps %!stylish-haskell'
  endif
endfunction

" Key bindings
augroup haskellStylish
  au!
  " Just hindent
  au FileType haskell nnoremap <leader>hi :Hindent<CR>
  " Just stylish-haskell
  au FileType haskell nnoremap <leader>hs :call HaskellFormat('stylish')<CR>
  " First hindent, then stylish-haskell
  au FileType haskell nnoremap <leader>hf :call HaskellFormat('both')<CR>
augroup END

" ----- parsonsmatt/intero-neovim -----

" Prefer starting Intero manually (faster startup times)
let g:intero_start_immediately = 1

" Use ALE (works even when not using Intero)
let g:intero_use_neomake = 0

" Enable type information on hover (when holding cursor at point for ~1 second).
let g:intero_type_on_hover = 1

" Change the intero window size; default is 10.
let g:intero_window_size = 15

" OPTIONAL: Make the update time shorter, so the type info will trigger faster.
set updatetime=1000


augroup interoMaps
  au!

  au FileType haskell nnoremap <silent> <leader>io :InteroOpen<CR>
  au FileType haskell nnoremap <silent> <leader>iov :InteroOpen<CR><C-W>H
  au FileType haskell nnoremap <silent> <leader>ih :InteroHide<CR>
  au FileType haskell nnoremap <silent> <leader>is :InteroStart<CR>
  au FileType haskell nnoremap <silent> <leader>ik :InteroKill<CR>

  au FileType haskell nnoremap <silent> <leader>wr :w \| :InteroReload<CR>
  au FileType haskell nnoremap <silent> <leader>il :InteroLoadCurrentModule<CR>
  au FileType haskell nnoremap <silent> <leader>if :InteroLoadCurrentFile<CR>

  au FileType haskell map <leader>t <Plug>InteroGenericType
  au FileType haskell map <leader>T <Plug>InteroType
  au FileType haskell nnoremap <silent> <leader>it :InteroTypeInsert<CR>

  au FileType haskell nnoremap <silent> <leader>jd :InteroGoToDef<CR>
  au FileType haskell nnoremap <silent> <leader>iu :InteroUses<CR>
  au FileType haskell nnoremap <leader>ist :InteroSetTargets<SPACE>
augroup END

" -- fast-tags --

augroup tags
au BufWritePost *.hs silent !init-tags %
au BufWritePost *.hsc silent !init-tags %
augroup END

" -- fzf --

" Customize fzf to use tabs for <Enter>
let g:fzf_action = {
  \ 'ctrl-m': 'tabedit',
  \ 'ctrl-o': 'e',
  \ 'ctrl-t': 'tabedit',
  \ 'ctrl-h':  'botright split',
  \ 'ctrl-v':  'vertical botright split' }

" Map `\o` to FZF file lister (Ctrl-T for new tab)
map <silent> <Leader>o :Files<CR>

" Map `\O` to FZF git file lister (Ctrl-T for new tab)
map <silent> <Leader>O :GFiles?<CR>

" -- vim-rooter --

" Only respect .git dir
let g:rooter_patterns = ['.git/']

" -- nerdcommenter --

" Add spaces after comment phrase
let g:NERDSpaceDelims = 1

" Comment in the same column
let g:NERDDefaultAlign = 'left'

" -- ale --

" Execution configs
let g:ale_linters = {}
let g:ale_linters['ruby'] = ['rubocop']
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_linters['javascript'] = ['eslint', 'flow']
let g:ale_linters['haskell'] = ['stack-ghc-mod', 'hlint']

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

" -- tagbar --

" Remove help from tagbar
let g:tagbar_compact = 1

" Set icon characters
let g:tagbar_iconchars = ['▸', '▾']

" Unfold tags to show current object
let g:tagbar_autoshowtag = 1

" Preview window position
let g:tagbar_previewwin_pos = "aboveleft"

" Automatically preview highlighted tag (can be annoying)
" let g:tagbar_autopreview = 1

" -- ale --

" -- git-gutter --

nmap <silent> <Leader>j :GitGutterNextHunk<CR>zz
nmap <silent> <Leader>k :GitGutterPrevHunk<CR>zz

" -- fzf.vim --

let g:fzf_history_dir = '~/.local/share/fzf-history'

command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview('up:60%')
  \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
  \                 <bang>0)

" -- IDE Feel --

" F1 opens NERDTree
nmap <silent> <F1> :NERDTreeFind<CR>
imap <silent> <F1> <Esc>:NERDTreeFind<CR>a

" F2 opens Tagbar
nmap <silent> <F2> :TagbarOpen<CR>
imap <silent> <F2> <Esc>:TagbarOpen<CR>a

" F3 closes Tagbar & NERDTree
nmap <silent> <F3> :TagbarClose<CR>:NERDTreeClose<CR>
imap <silent> <F3> <Esc>:TagbarClose<CR>:NERDTreeClose<CR>a

" F4 focus rotation
nmap <silent> <F4> :wincmd w<CR>
imap <silent> <F4> <Esc>:wincmd w<CR>a

" F5 re-enables syntax
nmap <silent> <F5> :syntax enable<CR>
imap <silent> <F5> <Esc>:syntax enable<CR>a

" Ctrl-F5 re-enables syntax in all tabs
nmap <silent> <C-F5> :tabdo syntax enable<CR>
imap <silent> <C-F5> <Esc>:tabdo syntax enable<CR>a

" Navigate Quickfixes with <C-J/L>
map <C-j> :cn<CR>
map <C-k> :cp<CR>

"}}}


"{{{ Must Be At End

" required for vim-textobj-rubyblock to work
runtime macros/matchit.vim

" Remember commands
set history=1000

"}}}


" set guicursor=n-v-c:block-Cursor
" set guicursor+=i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150
" set guicursor+=n-v-c:blinkon0
" set guicursor+=i:blinkwait10

