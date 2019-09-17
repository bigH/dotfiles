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

" -- GENERAL --
" status line and other edgy niceties
Plugin 'vim-airline/vim-airline'

" NERDTree and git support
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
"
" tagbar is sweet - don't use it much though
Plugin 'majutsushi/tagbar'

" `fzf` support
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" git info in the gutter
Plugin 'airblade/vim-gitgutter'

" gruvbox color scheme
Plugin 'morhetz/gruvbox'

" not always used, but useful for `scratch`
Plugin '907th/vim-auto-save'

" sweet plugin that shows `fzf` if more than one tag matches a <C-]>
Plugin 'zackhsi/fzf-tags'

" snippet engine for vim and a snippet library
Plugin 'SirVer/UltiSnips'
Plugin 'honza/vim-snippets'

" linting integration
Plugin 'dense-analysis/ale'

" -- LANGUAGES --
" ruby language pack
" motions `[` and `]` support ruby; `[ai][mM]` for methods and classes
Plugin 'vim-ruby/vim-ruby'
" puppet language pack
" TODO
Plugin 'rodjek/vim-puppet'

" -- EDITING --
" close with `end` when typing `\n` after `if`, `unless`, `begin`, etc.
Plugin 'tpope/vim-endwise'

" surround things with `()`, etc.
Plugin 'tpope/vim-surround'

" enables repetition of many things
Plugin 'tpope/vim-repeat'

" comment toggling with  `cm<motion>`
Plugin 'tpope/vim-commentary'

" replace with register `gr` (a paste operator which doesn't yank)
Plugin 'vim-scripts/ReplaceWithRegister'

" automatically closes things you open `()`, `[]`, etc.
Plugin 'Townk/vim-autoclose'

" highlights whitespace where it's not desired
Plugin 'ntpeters/vim-better-whitespace'

" enables all the below `textobj` plugins
Plugin 'kana/vim-textobj-user'

" adds motion to select indent level (`ii`) or do so ignoring `\n` (`ai`)
Plugin 'kana/vim-textobj-indent'

" adds `ie` or `ae` to select entire buffer
Plugin 'kana/vim-textobj-entire'

" adds `al` and `il` to select a line with and without indent (respectively)
Plugin 'kana/vim-textobj-line'

" adds a `i,` and `a,` motion for parameters (works on kwargs)
Plugin 'b4winckler/vim-angry'

" adds `%`, `[aigz[]]%`
Plugin 'andymass/vim-matchup'

" adds a `iv` and `av` motion for variable segments (camel or snake case)
Plugin 'Julian/vim-textobj-variable-segment'

" adds a `iq` and `aq` motion to cover `[ai][`'"]`
Plugin 'beloglazov/vim-textobj-quotes'

" adds highlighting to indicate indent level
Plugin 'nathanaelkane/vim-indent-guides'

" `sj` to join and `sk` to split - supports various ruby awesomeness
Plugin 'AndrewRadev/splitjoin.vim'

" `cx<motion>` to mark an item for exchange, do it again (supports `.`) and
" items are exchanged
Plugin 'tommcdo/vim-exchange'

" `g<l|L><motion><character|/pattern>` to align by padding left (`l`) or right
" (`L`) of the
Plugin 'tommcdo/vim-lion'

" nvim-only plugins
if has('nvim')
  " For LSP support
  Plugin 'autozimu/LanguageClient-neovim'
endif

" Plugin that provides a concentration writing mode
Plugin 'junegunn/goyo.vim'

" doesn't work properly, just use cgn
" Plugin 'terryma/vim-multiple-cursors'

" Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'

call vundle#end()

" Turn filetype back on after Vundle
filetype on
filetype plugin on

"}}}
