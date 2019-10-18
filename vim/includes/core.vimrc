let $NVIM_TUI_ENABLE_TRUE_COLOR=1

"{{{ Misc

set fileencodings=utf-8
set encoding=utf-8

" Enable hidden buffers
set hidden

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
" ... unless using capital letters
set smartcase
" ... also make <C-P> menu autocomplete regardless of input text case
set infercase

" set visualbell, to silence the annoying audible bell
set vb

" Move backups and temps into home directory
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

" Save undo-history
set undolevels=5000
set undodir=~/.vim/undodir
set undofile

" Indent wrapped lines up to the same level
if exists('&breakindent')
  set breakindent

  " shift wrapped content 2 spaces and use showbreak below
  set breakindentopt=shift:2,sbr
  set showbreak=>>

  " break at words
  set linebreak
endif

" Turn off wrapping - can be turned on and will automatically use above config as needed
set nowrap

" Unfold everything by default
set nofoldenable

" Use the mouse
set mouse=a

" Put tags in the `.tags` file - `$PROJECT_ROOT/.tags`
set tags=.tags

" Auto read files when they change
set autoread

" Reload edited files.
augroup BetterAutoread
  autocmd FocusGained * checktime
  autocmd BufEnter * checktime
augroup end

" Update time is used by CursorHold events as well as to write swap file
" This setting is kind of fast, but it makes HighlightCursorWord work nicely
set updatetime=400

" Highlight cursor line
set cursorline

" File-type specific stuff on
filetype on
filetype plugin on

" Split Naturally
set splitbelow
set splitright

"}}}


"{{{ Copy to OS Clipboard

function! CopyRegisterToClipboard(name)
  let contents = getreg(a:name)
  silent! call setreg('*', l:contents)
  silent! call setreg('+', l:contents)
endfunction

autocmd TextYankPost * call CopyRegisterToClipboard(v:event.regname)

"}}}


"{{{ Text Formatting

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
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·

" backspace should eat all
set backspace=indent,eol,start

" shift to multiples of tabstop
set shiftround

"}}}


"{{{ Highlighting

function! s:HighlightTabsIfExpandTabSet()
  if &expandtab
    match Error /\t/
  else
    match Error /\t/
  endif
endfunction

au OptionSet expandtab call <SID>HighlightTabsIfExpandTabSet()

highlight ExtraWhitespace ctermbg=red guibg=red
highlight Comment cterm=italic gui=italic

au ColorScheme * highlight ExtraWhitespace guibg=red

au BufEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\s\+$/

" Desired `highlight` in comments
augroup Todos
  au!
  au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|NB):/
        \ containedin=.*Comment,vimCommentTitle
augroup END

highlight def link MyTodo Todo


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
nnoremap <CR> :

" <leader><leader> to save
noremap <leader><leader> :w<CR>

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


"{{{ Useful Mappings

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

" Up and down are more logical with g..
nnoremap <silent> k gk
nnoremap <silent> j gj

" Alt-Enter or <leader><CR> - insert a new-line here
nnoremap <silent> <leader><CR> i<CR><Esc>
nnoremap <silent> <M-CR> i<CR><Esc>

" Sane Y
nnoremap <silent> Y y$

" Use Y to append in visual mode
vnoremap <silent> Y "Yy

" Map K to `NoOp`
nnoremap <silent> K <Nop>

" Map Q to `NoOp`
nnoremap <silent> K <Nop>

" Prevent (mis|slow)-types of below from triggering orignal vim commands
" NB: Later get re-mapped to using `vim-surround`
nnoremap <silent> s <Nop>
nnoremap <silent> S <Nop>

" `macOS` emulation
" TODO map <Command-BS> in iTerm/Alacritty
imap <silent> <M-BS> <C-W>

" `bash` emulation
imap <silent> <C-A> <Esc>I
imap <silent> <C-E> <Esc>A
imap <silent> <C-B> <Esc>bi
imap <silent> <C-F> <Esc>wi

" use <CR> to select from pop-up menu
" NB: this mapping conflicts with endwise, which also remaps `<CR>`
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

"}}}


"{{{ Terminal Things

" Terminal Mappings (neovim-only)
if has('nvim')
  " Defaults for certain files
  augroup TerminalSettings
    " Terminal Defaults
    au TermOpen * if &buftype == 'terminal' |
          \   setlocal nonumber |
          \   setlocal norelativenumber |
          \   setlocal scrolloff=0 |
          \   startinsert |
          \   tnoremap <Esc> <C-\><C-n> |
          \   tnoremap <silent> <M-h> <C-\><C-n>:wincmd h<CR>i |
          \   tnoremap <silent> <M-j> <C-\><C-n>:wincmd j<CR>i |
          \   tnoremap <silent> <M-k> <C-\><C-n>:wincmd k<CR>i |
          \   tnoremap <silent> <M-l> <C-\><C-n>:wincmd l<CR>i |
          \ endif

    " Auto-Close
    au TermClose * q

    " Handle <Esc>
    au FileType fzf tunmap <Esc>
  augroup END
endif

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

execute "source" $DOT_FILES_DIR . "/vim/custom/blinkenmatchen.vimrc"
execute "source" $DOT_FILES_DIR . "/vim/custom/visual_star.vimrc"
execute "source" $DOT_FILES_DIR . "/vim/custom/highlight_cursor_word.vimrc"
execute "source" $DOT_FILES_DIR . "/vim/custom/duplicate.vimrc"
execute "source" $DOT_FILES_DIR . "/vim/custom/change_repeat.vimrc"

"}}}


"{{{ Load Plugins

execute "source" $DOT_FILES_DIR . "/vim/includes/plugins.vimrc"
execute "source" $DOT_FILES_DIR . "/vim/includes/plugin_configs.vimrc"

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

"}}}


"{{{ Colors

" Use correct vim colors
if !empty(globpath(&rtp, 'colors/gruvbox.vim'))
  let g:gruvbox_italic=1
  colorscheme gruvbox
  let g:airline_theme='gruvbox'
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


