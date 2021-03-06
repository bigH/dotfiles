"{{{ True Color Support

" BREAKS MOST COLOR CHOICES
" when selecting guifg=foo, it won't render the same as ctermfg=foo

" let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" if exists('+termguicolors')
"   let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
"   let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
"   set termguicolors
" endif

"}}}


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
set backupdir=~/.vim/backup//
set directory=~/.vim/tmp//

" Save undo-history
set undolevels=5000
set undoreload=5000
set undodir=~/.vim/undodir//
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

" When prose-ing, `J` doesnt put two spaces between sentences
set nojoinspaces

" Use the mouse
set mouse=a
set mousehide

" Put tags in the default location - only search PWD
set tags=tags

" Auto read files when they change
set autoread

" Reload edited files.
augroup BetterAutoread
  autocmd FocusGained * checktime
  autocmd FocusGained * redraw
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

" TODO: Fix Splits when Resizing
" autocmd VimResized * wincmd =

"}}}


"{{{ Basic Window Management

" Kill current split
nmap <silent> <M-x> :close<CR>
imap <silent> <M-x> <Esc>:close<CR>
nmap <silent> <M-X> :only<CR>
imap <silent> <M-X> <Esc>:only<CR>

" Move between windows using <M-H/J/K/L> keys
nmap <silent> <M-h> :wincmd h<CR>
imap <silent> <M-h> <Esc>:wincmd h<CR>
nmap <silent> <M-j> :wincmd j<CR>
imap <silent> <M-j> <Esc>:wincmd j<CR>
nmap <silent> <M-k> :wincmd k<CR>
imap <silent> <M-k> <Esc>:wincmd k<CR>
nmap <silent> <M-l> :wincmd l<CR>
imap <silent> <M-l> <Esc>:wincmd l<CR>

" Split windows using <M-S-H/J/K/L> keys
nmap <silent> <M-H> :vsplit<CR>:wincmd h<CR>
imap <silent> <M-H> <Esc>:vsplit<CR>:wincmd h<CR>
nmap <silent> <M-J> :split<CR>
imap <silent> <M-J> <Esc>:split<CR>
nmap <silent> <M-K> :split<CR>:wincmd k<CR>
imap <silent> <M-K> <Esc>:split<CR>:wincmd k<CR>
nmap <silent> <M-L> :vsplit<CR>
imap <silent> <M-L> <Esc>:vsplit<CR>


"}}}


"{{{ Copy to all OS clipboards

let g:copy_all_registers_to_clipboard = 0

function! CopyPlusToStar(name)
  if g:copy_all_registers_to_clipboard || a:name == '+'
    let contents = getreg(a:name)
    if a:name == '+'
      silent! call setreg('*', l:contents)
    endif
    if a:name == '+'
      silent! call setreg('+', l:contents)
    endif
  endif
endfunction

autocmd TextYankPost * call CopyPlusToStar(v:event.regname)

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

highlight ExtraWhitespace ctermbg=red guibg=red
highlight Comment cterm=italic gui=italic

au ColorScheme * highlight ExtraWhitespace guibg=red

au BufEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhiteSpace /\s\+$/

" Desired `highlight` in comments
augroup Todos
  au Syntax * syn match MyTodo
        \ /\v<(FIXME|NOTES|NOTE|TODO|OPTIMIZE|MISSING|XXX|PR|NB):/
        \ containedin=.*Comment,vimCommentTitle
augroup END

highlight def link MyTodo Todo

"}}}


"{{{ UI

" Show the cursor position all the time
set ruler

" Display current mode
set showmode

" Set scroll
set scroll=5

" Delete comment character when joining lines
set formatoptions+=j


"}}}


"{{{ Core Mappings

" <space> is usually a motion meaning the same as 'l' (one letter forward)
" Much more useful if we make it be <leader>!
" (Uses map instead of mapleader so that this doesn't affect insert mode.)
nmap <space> <leader>

" <CR> is easier for me to hit on my keyboard than :
nnoremap <CR> :

" <leader><leader> to save
noremap <silent> <leader><leader> :wa<CR>
noremap <silent> <Space><Space> :wa<CR>

" this is useful for plugins to define `dd` equivalents
onoremap <Plug>(line-object) _

"}}}


"{{{ Auto Commands

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim). Don't do it for git commit messages.
autocmd BufReadPost *
  \ if stridx(expand('%'), '.git/COMMIT_EDITMSG') < 0 && line("'\"") > 0 && line("'\"") <= line("$") |
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

" Use `Y` to append text to clipboard & `<leader>Y` to clear
execute "source" $DOT_FILES_DIR . "/" . "vim/includes/get_visual_selection.vim"

vnoremap <silent> <Leader>Y :<C-U>let @+ .= GetVisualSelectionAsString()<CR>
vnoremap <silent> <Leader>y :<C-U>let @+ = GetVisualSelectionAsString()<CR>

nnoremap <silent> <Leader>Y "+y_
nnoremap <silent> <Leader>y "+y

nnoremap <silent> yp :<C-U>let @+ = expand('%')<CR>:<C-U>let @" = expand('%')<CR>

" Map K to `NoOp`
nnoremap <silent> K <Nop>

" Map Q to `NoOp`
nnoremap <silent> Q <Nop>

" Map `&` to `:&&`, which preserves all flags and performs the substitute
" again (faithfully) - `g&` will do the same with a new search (using
" anything that touches the `@/` register (which `search_utils` uses)
nnoremap <silent> & :<C-U>&&<CR>

" Prevent (mis|slow)-types of below from triggering orignal vim commands
" NB: Later get re-mapped to using `vim-surround` when loading plugins
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
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<C-G>u\<CR>"

" this seems hacky
" allow the . to execute once for each line of a visual selection
vnoremap <silent> . :normal .<CR>

" make using the line object easier
onoremap <silent> <CR> _

" Resize the current vertical split (either larger or smaller)
nnoremap <silent> <leader>= :exe "vertical resize " . (max([winwidth(0) + 1, winwidth(0) * 5/4]))<CR>
nnoremap <silent> <leader>- :exe "vertical resize " . (min([winwidth(0) - 1, winwidth(0) * 4/5]))<CR>

" Resize the current horizontal split (either larger or smaller)
nnoremap <silent> <leader>+ :exe "resize " . max([winheight(0) + 1, winheight(0) * 5/4])<CR>
nnoremap <silent> <leader>_ :exe "resize " . min([winheight(0) - 1, winheight(0) * 4/5])<CR>

"}}}


"{{{ Terminal Things

" Terminal Mappings (neovim-only)
if has('nvim')
  " Defaults for certain files
  augroup TerminalSettings
    " Show relative numbers on the left side
    set relativenumber
    set number

    " Don't allow cursor to be at edges
    set scrolloff=3
    set sidescrolloff=15

    " Status line gnarliness
    set laststatus=2
    set statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

    " TODO does this work properly?
    " `autocmd`
    au! TermOpen * if &buftype == 'terminal' |
          \   setlocal laststatus=0 |
          \   setlocal nonumber |
          \   setlocal norelativenumber |
          \   setlocal scrolloff=0 |
          \   setlocal sidescrolloff=0 |
          \   tnoremap <Esc> <C-\><C-n> |
          \   tnoremap <silent> <M-h> <C-\><C-n>:wincmd h<CR>i |
          \   tnoremap <silent> <M-j> <C-\><C-n>:wincmd j<CR>i |
          \   tnoremap <silent> <M-k> <C-\><C-n>:wincmd k<CR>i |
          \   tnoremap <silent> <M-l> <C-\><C-n>:wincmd l<CR>i |
          \   startinsert |
          \ endif |
          \ autocmd BufLeave <buffer> set relativenumber |
          \                           set number |
          \                           set scrolloff=3 |
          \                           set sidescrolloff=15 |
          \                           set laststatus=2

    " Auto-Close - conflicts with FZF floating window
    " au TermClose * q
    au WinEnter * if &buftype == 'terminal' |
          \   startinsert |
          \ endif

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

execute "source" $DOT_FILES_DIR . "/" . "vim/custom/duplicate.vim"
execute "source" $DOT_FILES_DIR . "/" . "vim/custom/highlight_cursor_word.vim"
execute "source" $DOT_FILES_DIR . "/" . "vim/custom/search_utils.vim"
execute "source" $DOT_FILES_DIR . "/" . "vim/custom/until.vim"

"}}}


"{{{ Easily Isolated Vim Configs

execute "source" $DOT_FILES_DIR . "/" . "vim/custom/abbrevs.vim"
execute "source" $DOT_FILES_DIR . "/" . "vim/includes/filetypes.vim"

"}}}


"{{{ Plugins

execute "source" $DOT_FILES_DIR . "/" . "vim/includes/plugins.vim"
execute "source" $DOT_FILES_DIR . "/" . "vim/includes/plugin_configs.vim"

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
  let g:airline_theme='gruvbox'
  let g:gruvbox_termcolors=256
  colorscheme gruvbox
endif

"}}}


"{{{ Cursor Stuff

" NeoVim and iTerm2 support displaying more cursor shapes than just a block.
if $ALACRITTY_LOG
  set guicursor=n-v-c:block-Cursor/lCursor-blinkon0
    \,i-ci:ver25-Cursor/lCursor
    \,r-cr:hor20-Cursor/lCursor
else
  set guicursor=n-v-c:block
    \,i-ci-ve:ver25
    \,r-cr:hor20
    \,o:hor50
    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
    \,sm:block-blinkwait175-blinkoff150-blinkon175
endif

" change cursor color in insert mode
" TODO does this work?
if &term =~ 'xterm' || &term =~ 'rxvt' || &term =~ 'screen'
  let &t_SI = "\<Esc>]12;#CCCCCC\x7"
  let &t_EI = "\<Esc>]12;#999999\x7"
endif

"}}}


"{{{ Must Be At End

" Remember commands
set history=1000

"}}}

