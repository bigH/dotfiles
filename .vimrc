"{{{ Misc

set fileencodings=utf-8
set encoding=utf-8

" Necesary  for lots of cool vim things
set nocompatible

" This shows what you are typing as a command.  I love this!
set showcmd

" Set syntax highlighting to always on
syntax enable

" Who doesn't like autoindent?
set autoindent

" No auto directory change
set noautochdir

" Use english for spellchecking, but don't spellcheck by default
if version >= 700
   set spl=en spell
   set nospell
endif

" Cool tab completion stuff
set path+=**
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

" Set off the other paren
highlight MatchParen ctermbg=4

" Move backups and temps into home directory
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

" Save undo-history
set undodir=~/.vim/undodir
set undofile

" Indent wrapped lines up to the same level
if exists('&breakindent')
  set breakindent

  " shift wrapped content 2 spaces and use showbreak below
  set breakindentopt=shift:6,sbr

  " use the >> to indicate wrapping
  set showbreak=>>>>

  " break at words
  set linebreak
endif

" Use the mouse
set mouse=a

" Put tags in the `.tags` file - `$PROJECT_ROOT/.tags`
set tags=.tags

" use ctags from brew if present
" TODO let g:tagbar_ctags_bin="/usr/local/Cellar/ctags/5.8_1/bin/ctags"

" TODO is this fine for buffers
" Use a new tab when opening quickfix items
" set switchbuf+=usetab,newtab

" Auto read files when they change
set autoread

" Force it on focus changes
au FocusGained * :checktime

" Setup Python
let g:python2_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

" Update time is used by CursorHold events as well as to write swap file
" This setting is kind of fast, but it makes HighlightCursorWord work nicely
set updatetime=200

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
set number

" Don't allow cursor to be at edges
set scrolloff=5
set sidescrolloff=20

" Automatically set scroll
autocmd BufEnter * set scroll=5

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

" 0 = methods
" 1 = quickfix
" 2 = git hunks
let g:jk_mode = 0

" Navigate methods by default
nmap <silent> <C-J> ]m
nmap <silent> <C-K> [m

func! JKModeRotate()
  if g:jk_mode == 0
    " Navigate quick-fix
    map <C-j> <Nop>
    map <C-k> <Nop>
    nmap <C-j> :cn<CR>
    nmap <C-k> :cp<CR>
    echo "QuickFix Mode"
    let g:jk_mode = 1
  elseif g:jk_mode == 1
    " Navigate git hunks
    map <silent> <C-J> :GitGutterNextHunk<CR>zz
    map <silent> <C-K> :GitGutterPrevHunk<CR>zz
    echo "Git Hunk Mode"
    let g:jk_mode = 2
  elseif g:jk_mode == 2
    " Navigate classes
    map <silent> <C-J> ]]
    map <silent> <C-K> [[
    echo "Class Mode"
    let g:jk_mode = 3
  else
    " Navigate methods
    map <silent> <C-J> ]m
    map <silent> <C-K> [m
    echo "Method Mode"
    let g:jk_mode = 0
  endif
  return
endfunc

" Paste Mode!  Dang! <F10>

nnoremap <silent> <leader>] :call JKModeRotate()<CR>

"}}}


"{{{ Line Number and Paste Cycle

let paste_mode = 0 " 0 = relative, 1 = paste, 2 = absolute

func! Paste_on_off()
  if g:paste_mode == 0
    nnoremap <silent> k k
    nnoremap <silent> j j
    sign unplace *
    set paste
    set nonumber
    set norelativenumber
    set nolist
    let g:paste_mode = 1
  elseif g:paste_mode == 1
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    retab
    set nopaste
    set number
    set norelativenumber
    set list
    let g:paste_mode = 2
  else
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    retab
    set nopaste
    set number
    set relativenumber
    set list
    let g:paste_mode = 0
  endif
  return
endfunc

" Paste Mode!  Dang! <F10>

nnoremap <silent> <F10> :call Paste_on_off()<CR>

"}}}


"{{{ Key Mappings

" Alt-Enter or <leader><CR> - insert a new-line here
nnoremap <silent> <CR> i<CR><Esc>
nnoremap <silent> <leader><CR> i<CR><Esc>
nnoremap <silent> <M-CR> i<CR><Esc>

" Sane Y
nnoremap <silent> Y y$

" Duplicate Selection
vnoremap <silent> <leader>d "dy"dP

" Copy to system clipboard
noremap <silent> <leader>y "+y
noremap <silent> <leader>Y "+y$

" Prevent (mis|slow)-types of below from triggering orignal vim commands
nnoremap <silent> s <Nop>
nnoremap <silent> S <Nop>

" Split Naturally
set splitbelow
set splitright

" Kill current split
nmap <silent> ss :close<CR>

" Make current split the only
nmap <silent> SS :only<CR>

" TODO ss/SS/[sS].? - closing and managing splits is painful - it'd be nice to
" close preview and such easily

" Move between windows
nmap <silent> sh :wincmd h<CR>
nmap <silent> sj :wincmd j<CR>
nmap <silent> sk :wincmd k<CR>
nmap <silent> sl :wincmd l<CR>

" Split Windows
nmap <silent> SH :vsplit<CR>:wincmd h<CR>
nmap <silent> SJ :split<CR>
nmap <silent> SK :split<CR>:wincmd k<CR>
nmap <silent> SL :vsplit<CR>

" Move Buffers
nmap <silent> <C-H> :bfirst!<CR>
nmap <silent> H :bprevious!<CR>
nmap <silent> L :bnext!<CR>
nmap <silent> <C-L> :blast!<CR>

" Remap Arrow Keys
map <Up> <Nop>
map <Down> <Nop>
map <Left> <Nop>
map <Right> <Nop>

" Up and down are more logical with g..
nnoremap <silent> k gk
nnoremap <silent> j gj

" TODO do I even use this anymore?
" Map <Space><Space> to save
nnoremap <silent> <Space><Space> :wa<Enter>

" Tag Navigation with Preview Window
" TODO do I even use this
nmap <silent> K :exec("ptag ".expand("<cword>"))<CR>

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
map <silent> N Nzz
map <silent> n nzz

" Remap Escape to train myself
" inoremap jk <Esc>
" inoremap kj <Esc>
" inoremap <Esc> <NOP>

" Disable Ex-Mode and map Q to close buffers
source ~/.hiren/vim_custom/kill_buffer_not_split.vimrc
nnoremap <silent> Q :call KillBufferNotSplit()<CR>

" Map Esc in `terminal`
noremap <Esc> <C-\><C-n>

" Map <leader>E to move to end of a match
onoremap <silent> <leader>E //e<CR>
nnoremap <silent> <leader>E //e<CR>

" Avoid deleting text while inserting that cannot be recovered
" NB: <c-g> allows invoking insert commands (in this case, u for undo)
" This somehow enables history tracking during these insert operations
inoremap <silent> <c-u> <c-g>u<c-u>
inoremap <silent> <c-w> <c-g>u<c-w>

" Map <M-Backspace> to delte previous word
" NB: we don't want `nore`, because ..
" <C-W> is mapped in a way that works with this (see right above)
imap <silent> <M-BS> <C-W>

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


"{{{ Custom Personal Stuff

source ~/.hiren/vim_custom/visual_star.vimrc
source ~/.hiren/vim_custom/highlight_cursor_word.vimrc
source ~/.hiren/vim_custom/stacktrace_browser.vimrc

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
Plugin '907th/vim-auto-save'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'zackhsi/fzf-tags'
Plugin 'vimtaku/hl_matchit.vim'
Plugin 'SirVer/UltiSnips'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-endwise'
Plugin 'Townk/vim-autoclose'
Plugin 'ntpeters/vim-better-whitespace'

" Plugin that provides a concentration writing mode
Plugin 'junegunn/goyo.vim'

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
augroup HaskellStylish
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

augroup InteroMaps
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

augroup HaskellTags
au BufWritePost *.hs silent !init-tags %
au BufWritePost *.hsc silent !init-tags %
augroup END

" -- fzf-tags --

" Replace <C-]> with fuzzy tag finder when more than one occurence of tag
nmap <silent> <C-]> <Plug>(fzf_tags)

" Map <C-\> to do this with vsplit
map <C-\> :vsplit<CR><Plug>(fzf_tags)

" -- fzf --

" Customize fzf to use tabs for <Enter>
let g:fzf_action = {
  \ 'ctrl-m': 'e!',
  \ 'ctrl-o': 'e!',
  \ 'ctrl-t': 'tabedit',
  \ 'ctrl-h': 'botright split',
  \ 'ctrl-v': 'vertical botright split' }

" Open old-files
command! RecentFiles call fzf#run({
\  'source':  v:oldfiles,
\  'sink':    'e',
\  'options': '-m -x +s',
\  'down':    '40%'})

" Map `\f` to FZF using `ripgrep`
nmap <silent> <leader>f :Lines<CR>

" Map `\t` to FZF tag finder
nmap <silent> <leader>t :Tags<CR>

" Map `\e` to FZF file lister
nmap <silent> <leader>e :Files<CR>

" Map `\o` to FZF file lister
nmap <silent> <leader>o :RecentFiles<CR>

" Map `\O` to FZF git file lister
nmap <silent> <leader>O :GFiles?<CR>

" Set history directory
let g:fzf_history_dir = '~/.local/share/fzf-history'

" -- nerdcommenter --

" Add spaces after comment phrase
let g:NERDSpaceDelims = 1

" Comment in the same column
let g:NERDDefaultAlign = 'left'

" -- ale --

" Execution configs
let g:ale_linters = {}
let g:ale_linters['ruby'] = ['rubocop']
let g:ale_linters['javascript'] = ['eslint', 'flow']
let g:ale_linters['haskell'] = ['stack-ghc-mod', 'hlint']

let g:ale_fixers = ['rubocop']

" Use `bundle`
let g:ale_ruby_rubocop_executable = 'bundle'

" Don't lint while typing
let g:ale_lint_on_text_changed = 'never'

" Show the full list of lint errors
let g:ale_open_list = 1

" Enable `ale` airline stuff
let g:airline#extensions#ale#enabled = 1

" Fix on Save (TODO)
" let g:ale_fix_on_save = 1

" -- nerd-tree --

" Set it to not show `? for help`
let NERDTreeMinimalUI = 1

" Auto-remove buffer of file just deleted
let NERDTreeAutoDeleteBuffer = 1

" -- airline --

" TODO
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffers_label = ''
let g:airline#extensions#tabline#tabs_label = ''

" -- vim-textobj-user --

" custom text object for ruby constant
call textobj#user#plugin('constant', {
\   'constant': {
\     'pattern': '\C\<\([_A-Z]\+[a-z]*\)\+\(::\([_A-Z]\+[a-z]*\)\+\)*\>',
\     'select': ['arc', 'irc'],
\   },
\ })

" -- vim-textobj-rubyblock --

" use longer mappings `ro`, `rl`, `rc`, `rd`, `rr`
let g:textobj_ruby_more_mappings = 1

" -- tagbar --

" Remove help from tagbar
let g:tagbar_compact = 1

" Stop auto-focus
let g:tagbar_autofocus = 0

" Set icon characters
let g:tagbar_iconchars = ['▸', '▾']

" Unfold tags to show current object
let g:tagbar_autoshowtag = 1

" Preview window position
let g:tagbar_previewwin_pos = "aboveleft"

" Automatically preview highlighted tag (can be annoying)
let g:tagbar_autopreview = 0

" Don't sort alphabetically
let g:tagbar_sort = 0

" ruby support
if executable('ripper-tags')
  let g:tagbar_type_ruby = {
      \ 'kinds'      : ['m:modules',
                      \ 'c:classes',
                      \ 'C:constants',
                      \ 'F:singleton methods',
                      \ 'f:methods',
                      \ 'a:aliases'],
      \ 'kind2scope' : { 'c' : 'class',
                        \ 'm' : 'class' },
      \ 'scope2kind' : { 'class' : 'c' },
      \ 'ctagsbin'   : 'ripper-tags',
      \ 'ctagsargs'  : ['-f', '-']
  \ }
else
  let g:tagbar_type_ruby = {
      \ 'kinds' : [
          \ 'm:modules',
          \ 'c:classes',
          \ 'd:describes',
          \ 'C:contexts',
          \ 'f:methods',
          \ 'F:singleton methods'
      \ ]
  \ }

endif

" -- vim-ruby --

" access modifiers align with definitions
let g:ruby_indent_access_modifier_style = 'normal'

" indent blocks
let g:ruby_indent_block_style = 'do'

" highlight ruby operators
let ruby_operators = 1
let ruby_pseudo_operators = 1

" folding
" let ruby_fold = 1

" set up folding to not fold everything
" let ruby_foldable_groups = 'def class module'

" set up folding to fold most things
" let ruby_foldable_groups = 'def class module do begin case for'

" -- git-gutter --

" TODO write a better modal list move method
nmap <silent> <leader>j :GitGutterNextHunk<CR>zz
nmap <silent> <leader>k :GitGutterPrevHunk<CR>zz

" -- IDE Feel --

" F1 opens NERDTree
nmap <silent> <F1> :NERDTreeFind<CR>
imap <silent> <F1> <Esc>:NERDTreeFind<CR>a

" F2 opens Tagbar
nmap <silent> <F2> :TagbarOpen<CR>
imap <silent> <F2> <Esc>:TagbarOpen<CR>a

" F3 closes Tagbar & NERDTree
nmap <silent> <F3> :TagbarClose<CR>:NERDTreeClose<CR>:pclose<CR>:cclose<CR>:lclose<CR>
imap <silent> <F3> <Esc>:TagbarClose<CR>:NERDTreeClose<CR>:pclose<CR>:cclose<CR>:lclose<CR>a

" F4 and <leader>b
nmap <silent> <F4> :Buffers<CR>
nmap <silent> <leader>b <Esc>:Buffers<CR>
imap <silent> <F4> <Esc>:Buffers<CR>

" NoOp function for use below
function! NoOp()
endfunction

" NoOp L/H/C-H/C-L in NERDTree
augroup NERDTree
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': 'H', 'callback': 'NoOp', 'override': 1 })
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<C-H>', 'callback': 'NoOp', 'override': 1 })
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': 'L', 'callback': 'NoOp', 'override': 1 })
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<C-L>', 'callback': 'NoOp', 'override': 1 })
augroup END

" NoOp L/H/C-H/C-L in Tagbar
augroup TagBar
  autocmd!
  autocmd FileType tagbar nnoremap <buffer> H <Nop>
  autocmd FileType tagbar nnoremap <buffer> L <Nop>
  autocmd FileType tagbar nnoremap <buffer> <C-H> <Nop>
  autocmd FileType tagbar nnoremap <buffer> <C-H> <Nop>
augroup END


" Desired `hi` in comments
augroup Todos
    au!
    au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|NB):/
          \ containedin=.*Comment,vimCommentTitle
augroup END
hi def link MyTodo Todo

"}}}


"{{{ Session Management

" Automatically load last session when no args given
autocmd VimEnter *
         \ call system('tail -n1000 ~/.vim/sessions/index > ~/.vim/sessions/index.truncated') |
         \ call system('mv ~/.vim/sessions/index.truncated ~/.vim/sessions/index') |
         \ if argc() == 0 |
         \   execute 'source' '~/.vim/sessions/last-session' |
         \ endif
         " \   call fzf#run({'source':  'cat ~/.vim/sessions/index',
         " \                 'sink':    'source',
         " \                 'options': '',
         " \                 'down':    '40%'}) |

" Automatically load last session when no args given
autocmd VimLeave *
         \ execute 'mksession!' '~/.vim/sessions/last-session' |
         \ let g:session_file = 'session-' . strftime('%Y-%m-%d') . '-' . strftime('%H-%M-%S') |
         \ execute 'mksession' ('~/.vim/sessions/' . g:session_file) |
         \ let g:branch = system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'") |
         \ let g:date_time = strftime('%Y.%m.%d %H:%M:%S') |
         \ let g:current_directory = trim(system('pwd')) |
         \ let g:content = g:current_directory . '\t' . g:branch . '\t' . g:date_time . '\t' . g:session_file |
         \ let g:session_index = '~/.vim/sessions/index' |
         \ call system('touch ' . g:session_index) |
         \ call system('echo "' . g:content . '" >> ' . g:session_index)


"}}}


"{{{ Environment-Specific

if filereadable(expand($DOT_FILES_DIR) . '/.' . expand($DOT_FILES_ENV) . '.vimrc')
  execute 'source' (expand($DOT_FILES_DIR) . '/.' . expand($DOT_FILES_ENV) . '.vimrc')
endif

"}}}


"{{{ Cursor Stuff

" change cursor color in insert mode
" TODO does this work?
if &term =~ "xterm" || &term =~ 'rxvt' || &term =~ 'screen'
  let &t_SI = "\<Esc>]12;#CCCCCC\x7"
  let &t_EI = "\<Esc>]12;#999999\x7"
endif

"}}}


"{{{ Must Be At End

" required for vim-textobj-rubyblock to work
runtime macros/matchit.vim

" enable `end` highlighting and paren highlighting
let g:hl_matchit_enable_on_vim_startup = 1

" use `top speed` setting
let g:hl_matchit_speed_level = 1

" Remember commands
set history=1000

"}}}


