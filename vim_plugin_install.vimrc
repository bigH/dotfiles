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
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'dense-analysis/ale'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'majutsushi/tagbar'
Plugin 'airblade/vim-gitgutter'
Plugin 'sheerun/vim-polyglot'
Plugin 'morhetz/gruvbox'
Plugin '907th/vim-auto-save'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'zackhsi/fzf-tags'
Plugin 'SirVer/UltiSnips'
Plugin 'honza/vim-snippets'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-commentary'
Plugin 'vim-scripts/ReplaceWithRegister'
Plugin 'Townk/vim-autoclose'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-indent'
Plugin 'kana/vim-textobj-entire'
Plugin 'kana/vim-textobj-line'
Plugin 'sgur/vim-textobj-parameter'
Plugin 'beloglazov/vim-textobj-quotes'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'autozimu/LanguageClient-neovim'

" Plugin that provides a concentration writing mode
Plugin 'junegunn/goyo.vim'

" doesn't work properly
" Plugin 'terryma/vim-multiple-cursors'

" Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'

call vundle#end()

" Turn filetype back on after Vundle
filetype on
filetype plugin on

"}}}
