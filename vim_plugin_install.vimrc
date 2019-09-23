"{{{ vim-plug

" Set the runtime path to include Vundle and initialize
call plug#begin('~/.vim/bundle')

" Let Vundle manage Vundle
Plug 'VundleVim/Vundle.vim'

" Plugins

" -- GENERAL --
" status line and other edgy niceties
Plug 'vim-airline/vim-airline'

" NERDTree and git support
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
"
" tagbar is sweet - don't use it much though
Plug 'majutsushi/tagbar'

" `fzf` support
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" git info in the gutter
Plug 'airblade/vim-gitgutter'

" gruvbox color scheme
Plug 'morhetz/gruvbox'

" not always used, but useful for `scratch`
Plug '907th/vim-auto-save'

" sweet plugin that shows `fzf` if more than one tag matches a <C-]>
Plug 'zackhsi/fzf-tags'

" snippet engine for vim and a snippet library
Plug 'SirVer/UltiSnips'
Plug 'honza/vim-snippets'

" linting integration
Plug 'dense-analysis/ale'

" -- LANGUAGES --
" ruby language pack
" motions `[` and `]` support ruby; `[ai][mM]` for methods and classes
Plug 'vim-ruby/vim-ruby'
" puppet language pack
" TODO
Plug 'rodjek/vim-puppet'

" -- EDITING --
" close with `end` when typing `\n` after `if`, `unless`, `begin`, etc.
Plug 'tpope/vim-endwise'

" surround things with `()`, etc.
Plug 'tpope/vim-surround'

" enables repetition of many things
Plug 'tpope/vim-repeat'

" comment toggling with  `cm<motion>`
Plug 'tpope/vim-commentary'

" replace with register `gr` (a paste operator which doesn't yank)
Plug 'vim-scripts/ReplaceWithRegister'

" automatically closes things you open `()`, `[]`, etc.
Plug 'Townk/vim-autoclose'

" highlights whitespace where it's not desired
Plug 'ntpeters/vim-better-whitespace'

" enables all the below `textobj` plugins
Plug 'kana/vim-textobj-user'

" adds motion to select indent level (`ii`) or do so ignoring `\n` (`ai`)
Plug 'kana/vim-textobj-indent'

" adds `ie` or `ae` to select entire buffer
Plug 'kana/vim-textobj-entire'

" adds `al` and `il` to select a line with and without indent (respectively)
Plug 'kana/vim-textobj-line'

" adds a `i,` and `a,` motion for parameters (works on kwargs)
Plug 'b4winckler/vim-angry'

" adds `%`, `[aigz[]]%`
Plug 'andymass/vim-matchup'

" adds a `iv` and `av` motion for variable segments (camel or snake case)
Plug 'Julian/vim-textobj-variable-segment'

" adds a `iq` and `aq` motion to cover `[ai][`'"]`
Plug 'beloglazov/vim-textobj-quotes'

" adds highlighting to indicate indent level
Plug 'nathanaelkane/vim-indent-guides'

" `sj` to join and `sk` to split - supports various ruby awesomeness
Plug 'AndrewRadev/splitjoin.vim'

" `cx<motion>` to mark an item for exchange, do it again (supports `.`) and
" items are exchanged
Plug 'tommcdo/vim-exchange'

" `g<l|L><motion><character|/pattern>` to align by padding left (`l`) or right
" (`L`) of the
Plug 'tommcdo/vim-lion'

" nvim-only plugins
if has('nvim')
  " For LSP support
  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
endif

" Plugin that provides a concentration writing mode `:Goyo`
Plug 'junegunn/goyo.vim'

" doesn't work properly, just use cgn
" Plug 'terryma/vim-multiple-cursors'

" Plug 'pangloss/vim-javascript'
" Plug 'mxw/vim-jsx'

" Initialize plugin system
call plug#end()

"}}}
