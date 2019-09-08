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

" Show :s and potentially other commands while typing
if exists('&inccommand')
  set inccommand=split
endif

" Get rid of obnoxious '-' characters in folds & diffs
set fillchars=fold:\ ,
set fillchars+=diff:\ ,

" Show column whenever textwidth is set
set colorcolumn=+0

" Ignore case in search
set ignorecase

" set visualbell, to silence the annoying audible bell
set vb

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

" Turn off wrapping - can be turned on and will automatically use above config as needed
set nowrap

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

" Reload edited files.
augroup improved_autoread
  autocmd FocusGained * checktime
  autocmd FocusGained * GitGutterAll
  autocmd BufEnter * checktime
  autocmd BufEnter * GitGutterAll
augroup end

" Setup Python
let g:python2_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

" Update time is used by CursorHold events as well as to write swap file
" This setting is kind of fast, but it makes HighlightCursorWord work nicely
set updatetime=200

" Highlight cursor line
set cursorline

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
set scrolloff=3
set sidescrolloff=15

" Automatically set scroll
autocmd BufEnter * set scroll=5

" Delete comment character when joining lines
set formatoptions+=j

" Status line gnarliness
set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

"}}}


"{{{ Core Mappings

" <space> is usually a motion meaning the same as 'l' (one letter forward)
" Much more useful if we make it be <leader>!
" (Uses map instead of mapleader so that this doesn't affect insert mode.)
nmap <space> <leader>
nmap \ <nop>

" <CR> is easier for me to hit on my keyboard than :
noremap <CR> :

" <leader><leader> to save
noremap <leader><leader> :w<CR>

" Re-indent when pasting
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

"}}}


"{{{ Auto Commands

" Defaults for certain files
augroup FiletypeSettings
  " Always use tabs in gitconfig
  au FileType gitconfig setlocal noexpandtab

  " Wrap long lines in quickfix windows
  au FileType qf setlocal wrap

  " Set cursorline in quickfix windows
  au FileType qf setlocal cursorline
augroup END

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

" 0 = git hunks
" 1 = quickfix
" 2 = loc-list
" 3 = methods
" 4 = classes
let g:jk_mode = 0

func! COpenIfApplicable()
  " close the other one
  lclose
  if len(getqflist()) == 0
    cclose
  else
    copen
    wincmd k
  endif
endfunc

func! LOpenIfApplicable()
  " close the other one
  cclose
  if len(getloclist(winnr())) == 0
    lclose
  else
    lopen
    wincmd k
  endif
endfunc

func! CloseBothLists()
  cclose
  lclose
endfunc

func! JKModeApply()
  if g:jk_mode == 0
    call CloseBothLists()
    echo "=> Git Hunk Mode"
  elseif g:jk_mode == 1
    call COpenIfApplicable()
    echo "=> QuickFix Mode"
  elseif g:jk_mode == 2
    call LOpenIfApplicable()
    wincmd k
    echo "=> Loc List Mode"
  elseif g:jk_mode == 3
    call CloseBothLists()
    echo "=> Method Mode"
  else
    call CloseBothLists()
    echo "=> Class Mode"
  endif
endfunc

func! Modulus(n,m)
  return ((a:n % a:m) + a:m) % a:m
endfunc

func! JKModeRotate(direction)
  let g:jk_mode = Modulus(g:jk_mode + a:direction, 5)
  call JKModeApply()
endfunc

func! JKModeJ()
  " TODO doesn't work
  " normal ml
  " match Search /\%'.line('.').'l/
  if g:jk_mode == 1
    try
      cnext
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 2
    try
      lnext
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 3
    normal ]m
  elseif g:jk_mode == 4
    normal ]]
  else
    GitGutterNextHunk
  endif
  " TODO doesn't work
  " match Search /\%'.line('.').'l/
endfunc

func! JKModeK()
  normal ml
  match Search /\%'.line('.').'l/
  if g:jk_mode == 1
    try
      cprevious
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 2
    try
      lprevious
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 3
    normal [m
  elseif g:jk_mode == 4
    normal [[
  else
    GitGutterPrevHunk
  endif
endfunc

" Rotate modes
nnoremap <silent> ]<leader>] :call JKModeRotate(1)<CR>
nnoremap <silent> <leader>] :call JKModeRotate(1)<CR>
nnoremap <silent> [<leader>[ :call JKModeRotate(-1)<CR>
nnoremap <silent> <leader>[ :call JKModeRotate(-1)<CR>

" Use current mode
nmap <silent> <C-J> :call JKModeJ()<CR>
nmap <silent> <C-K> :call JKModeK()<CR>


"}}}


"{{{ Line Number and Paste Cycle

let paste_mode = 0 " 0 = relative, 1 = paste, 2 = absolute

func! Paste_on_off()
  if g:paste_mode == 0
    call NoIncrementalUndo()
    nnoremap <silent> k k
    nnoremap <silent> j j
    sign unplace *
    set paste
    set nonumber
    set norelativenumber
    set nolist
    let g:paste_mode = 1
  elseif g:paste_mode == 1
    call IncrementalUndo()
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    retab
    set nopaste
    set number
    set norelativenumber
    set list
    let g:paste_mode = 2
  else
    call IncrementalUndo()
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


"{{{ Terminal Mappings (neovim-only)
if has('nvim')
  " TODO

  " Defaults for certain files
  augroup TerminalSettings
    " Terminal Defaults
    au TermOpen * setlocal nonumber
    au TermOpen * setlocal norelativenumber
    au TermOpen * setlocal scrolloff=0
    au TermOpen * startinsert

    " Auto-Close
    au TermClose * q

    " Handle <Esc>
    au TermOpen * tnoremap <Esc> <C-\><C-n>
    au FileType fzf tunmap <Esc>

    " Window Switching
    au TermOpen * tnoremap <silent> <M-h> <C-\><C-n>:wincmd h<CR>
    au TermOpen * tnoremap <silent> <M-j> <C-\><C-n>:wincmd j<CR>
    au TermOpen * tnoremap <silent> <M-k> <C-\><C-n>:wincmd k<CR>
    au TermOpen * tnoremap <silent> <M-l> <C-\><C-n>:wincmd l<CR>
  augroup END

endif
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

" Move between windows using <M-H/J/K/L> keys
nmap <silent> <M-h> :wincmd h<CR>
nmap <silent> <M-j> :wincmd j<CR>
nmap <silent> <M-k> :wincmd k<CR>
nmap <silent> <M-l> :wincmd l<CR>

" Move between windows using <M-H/J/K/L> keys
imap <silent> <M-h> :wincmd h<CR>
imap <silent> <M-j> :wincmd j<CR>
imap <silent> <M-k> :wincmd k<CR>
imap <silent> <M-l> :wincmd l<CR>

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

" Move in insert mode using <C-H/J/K/L> keys
inoremap <silent> <C-H> <Left>
inoremap <silent> <C-J> <Down>
inoremap <silent> <C-K> <Up>
inoremap <silent> <C-L> <Right>

" Use <M-J/K> when in insert mode to handle <C-J/K>
inoremap <silent> <M-j> <Esc><C-J>I
inoremap <silent> <M-k> <Esc><C-K>I

" Up and down are more logical with g..
nnoremap <silent> k gk
nnoremap <silent> j gj

" Turn of `K`
" TODO consider setting keywordprg
nmap <silent> K <Nop>

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nmap <silent> N Nzz
nmap <silent> n nzz

" Remap Escape to train myself
" inoremap jk <Esc>
" inoremap kj <Esc>
" inoremap <Esc> <NOP>

" Disable Ex-Mode and map Q to close buffers
source ~/.hiren/vim_custom/kill_buffer_not_split.vimrc
nnoremap <silent> Q :call KillBufferNotSplit()<CR>

" Avoid deleting text while inserting that cannot be recovered
inoremap <silent> <c-u> <c-g>u<c-u>
inoremap <silent> <c-w> <c-g>u<c-w>

" Make undo work more incrementally
func! IncrementalUndo()
  inoremap . .<C-g>u
  inoremap ! !<C-g>u
  inoremap ? ?<C-g>u
  inoremap : :<C-g>u
  inoremap ; ;<C-g>u
  inoremap , ,<C-g>u
endfunc

func! NoIncrementalUndo()
  iunmap .
  iunmap !
  iunmap ?
  iunmap :
  iunmap ;
  iunmap ,
endfunc

call IncrementalUndo()

" -- pop-up-menu bindings
" inoremap <expr> <TAB> pumvisible() ? "\<C-y>" : "\<CR>"
" inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
" inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Down>"
" inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<Up>"

" -- `macOS` emulation
" Map <M-Backspace> to delte previous word
" NB: we don't want `nore`, because ..
" <C-W> is mapped in a way that works with this (see right above)
imap <silent> <M-BS> <C-W>

" -- TODO easier navigation in insert mode
" imap <silent> <C-H>

" -- `bash` emulation
imap <silent> <C-A> <Esc>I
imap <silent> <C-E> <Esc>A
imap <silent> <C-B> <Esc>bi
imap <silent> <C-F> <Esc>wi

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

source ~/.hiren/vim_plugin_install.vimrc

"}}}


"{{{ Vundle

" TODO make this use `$DOT_FILE_ENV`
" source ~/.hiren/.stripe.vimrc

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

" -- fzf-tags --

" Replace <C-]> with fuzzy tag finder when more than one occurence of tag
nmap <silent> <C-]> <Plug>(fzf_tags)

" Map <C-\> to do this with vsplit
nmap <C-\> :vsplit<CR><Plug>(fzf_tags)

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

func! FzfFindInDirectoryfunc()
  wincmd l
  call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case '.
        \   shellescape(<q-args>).' '.
        \   substitute(g:NERDTreeFileNode.GetSelected().path.str(), getcwd() . "/" , "", ""),
        \   0,
        \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] })
endfunc

command! FzfFindInDirectory call FzfFindInDirectoryFunction()

" Make `\f` search in a given directory using fzf#run
augroup NERDTree
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<Leader>f', 'callback': 'FzfFindInDirectoryFunction', 'override': 1 })
augroup END

" Map `\f` to FZF search all open files
nmap <silent> <leader>f :Lines<CR>

" Map `\t` to FZF tag finder
nmap <silent> <leader>t :Tags<CR>

" Map `\e` to FZF file lister
nmap <silent> <leader>e :Files<CR>

" Map `\o` to FZF file lister
nmap <silent> <leader>o :RecentFiles<CR>

" Map `\O` to FZF git file lister
nmap <silent> <leader>O :GFiles?<CR>

" Augmenting Rg command using fzf#vim#with_preview function
"   :Rg  - Start fzf with hidden preview window that can be enabled with "?" key
"   :Rg! - Start fzf in fullscreen and display the preview window above
command! -bang -nargs=* Rg
  \ call fzf#vim#rg(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview('up:60%')
  \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
  \                 <bang>0)

" Set history directory
let g:fzf_history_dir = '~/.local/share/fzf-history'

" -- ale --

" Symbols to use
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '▲'

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
" let g:ale_open_list = 1

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

" TODO go back to tabs
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffers_label = ''
let g:airline#extensions#tabline#tabs_label = ''

" -- vim-textobj-user --

source ~/.hiren/vim_custom/text_objects.vimrc

let g:vim_textobj_parameter_mapping = ','

" -- tagbar --


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
      \ 'ctagsargs'  : '--fields=+n -f -'
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

" functions for use below to make NERDTree switch windows in the editor region
func! NERDBPrev()
  execute 'wincmd' 'l'
  execute 'bprev'
endfunc

func! NERDBFirst()
  execute 'wincmd' 'l'
  execute 'bfirst'
endfunc

func! NERDBNext()
  execute 'wincmd' 'l'
  execute 'bnext'
endfunc

func! NERDBLast()
  execute 'wincmd' 'l'
  execute 'blast'
endfunc

" L/H/C-H/C-L in NERDTree
augroup NERDTree
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': 'H', 'callback': 'NERDBPrev', 'override': 1 })
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<C-H>', 'callback': 'NERDBFirst', 'override': 1 })
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': 'L', 'callback': 'NERDBNext', 'override': 1 })
  autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<C-L>', 'callback': 'NERDBLast', 'override': 1 })
augroup END

" L/H/C-H/C-L in Tagbar
augroup TagBar
  autocmd!
  autocmd FileType tagbar nnoremap <buffer> H :wincmd h<CR>:bprev<CR>
  autocmd FileType tagbar nnoremap <buffer> <C-H> :wincmd h<CR>:bfirst<CR>
  autocmd FileType tagbar nnoremap <buffer> L :wincmd h<CR>:bnext<CR>
  autocmd FileType tagbar nnoremap <buffer> <C-L> :wincmd h<CR>:blast<CR>
augroup END


" Desired `hi` in comments
augroup Todos
    au!
    au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|NB):/
          \ containedin=.*Comment,vimCommentTitle
augroup END
hi def link MyTodo Todo

" -- vim-indent-guides --

" enable at start-up
let g:indent_guides_enable_on_vim_startup = 1

" configure colors
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=black
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=NONE

"}}}


"{{{ Session Management

" Automatically load last session when no args given
autocmd VimEnter *
         \ call system('tail -n1000 ~/.vim/sessions/index > ~/.vim/sessions/index.truncated') |
         \ call system('mv ~/.vim/sessions/index.truncated ~/.vim/sessions/index') |
         \ if argc() == 0 |
         \   call fzf#run({'source':  'cat ~/.vim/sessions/index',
         \                 'sink':    'source',
         \                 'options': '',
         \                 'down':    '40%'}) |
         \ endif

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

" Remember commands
set history=1000

"}}}


