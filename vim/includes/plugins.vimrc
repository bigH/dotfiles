if !exists('g:app_plugin_set')
  if has('nvim')
    let g:app_plugin_set = 'nvim'
  else
    let g:app_plugin_set = 'vim'
  endif
endif

function! ExcludeModes(...)
  let cond = 0
  for arg in a:000
    if g:app_plugin_set == arg
      let cond = 1
    endif
  endfor
  return l:cond ? { 'on': [] } : {}
endfunction

function! ForModes(...)
  let cond = 0
  for arg in a:000
    if g:app_plugin_set == arg
      let cond = 1
    endif
  endfor
  return l:cond ? {} : { 'on': [] }
endfunction

let g:loaded_plugins = []

function! PlugMemoizeFunction(name, ...)
  let conf = {}
  for arg in a:000
    let conf = extend(conf, arg)
  endfor
  if !has_key(l:conf, 'on') || len(l:conf['on'])
    call add(g:loaded_plugins, a:name)
  endif
  Plug a:name, l:conf
endfunction

command! -nargs=+ -bar PlugMemoize call PlugMemoizeFunction(<args>)

function! IsPluginLoaded(...)
  for name in a:000
    let plugin_loaded = 0
    for loaded_plugin in g:loaded_plugins
      if l:loaded_plugin == l:name
        let plugin_loaded = 1
      endif
    endfor
    if l:plugin_loaded == 0
      return 0
    endif
  endfor
  return 1
endfunction

" -- PLUGINS --
call plug#begin('~/.vim/bundle')

" For helptags only
PlugMemoize 'junegunn/vim-plug'

" -- GENERAL --
" status line and other edgy niceties
PlugMemoize 'vim-airline/vim-airline', ForModes('vim', 'nvim')

" NERDTree and git support
PlugMemoize 'scrooloose/nerdtree', ForModes('vim', 'nvim')
PlugMemoize 'Xuyuanp/nerdtree-git-plugin', ForModes('vim', 'nvim')
"
" tagbar is sweet - don't use it much though
PlugMemoize 'majutsushi/tagbar', ForModes('vim', 'nvim')

" `fzf` support
PlugMemoize 'junegunn/fzf'
PlugMemoize 'junegunn/fzf.vim'

" git info in the gutter
PlugMemoize 'airblade/vim-gitgutter', ForModes('vim', 'nvim')

" gruvbox color scheme
PlugMemoize 'morhetz/gruvbox'

" not always used, but useful for `scratch` and `journal`
PlugMemoize '907th/vim-auto-save', ExcludeModes('vim', 'nvim')

" sweet plugin that shows `fzf` if more than one tag matches a <C-]>
PlugMemoize 'zackhsi/fzf-tags', ForModes('vim', 'nvim')

" snippet engine for vim and a snippet library
PlugMemoize 'SirVer/UltiSnips', ForModes('vim', 'nvim')
PlugMemoize 'honza/vim-snippets', ForModes('vim', 'nvim')

" linting integration
PlugMemoize 'dense-analysis/ale', ForModes('vim', 'nvim')

" -- LANGUAGES --
" ruby language pack
" motions `[` and `]` support ruby; `[ai][mM]` for methods and classes
PlugMemoize 'vim-ruby/vim-ruby'

" scala language pack
" TODO ??
PlugMemoize 'derekwyatt/vim-scala'

" -- EDITING --
" `vimwiki` potentially for use in journal
PlugMemoize 'vimwiki/vimwiki', ForModes('journal')

" close with `end` when typing `\n` after `if`, `unless`, `begin`, etc.
" NB: this plugin remaps <CR> and causes weird issues when using <C-P>
" PlugMemoize 'tpope/vim-endwise', ForModes('vim', 'nvim')

" surround things with `()`, etc.
PlugMemoize 'tpope/vim-surround'

" enables repetition of many things
PlugMemoize 'tpope/vim-repeat'

" comment toggling with  `cm<motion>`
PlugMemoize 'tpope/vim-commentary'

" replace with register `gr` (a paste operator which doesn't yank)
PlugMemoize 'vim-scripts/ReplaceWithRegister'

" automatically closes things you open `()`, `[]`, etc.
PlugMemoize 'Townk/vim-autoclose'

" highlights whitespace where it's not desired
PlugMemoize 'ntpeters/vim-better-whitespace'

" enables all the below `textobj` plugins
PlugMemoize 'kana/vim-textobj-user'

" adds motion to select indent level (`ii`) or do so ignoring `\n` (`ai`)
PlugMemoize 'kana/vim-textobj-indent'

" adds `ie` or `ae` to select entire buffer
PlugMemoize 'kana/vim-textobj-entire'

" adds `al` and `il` to select a line with and without indent (respectively)
PlugMemoize 'kana/vim-textobj-line'

" adds a `i,` and `a,` motion for parameters (works on kwargs)
PlugMemoize 'b4winckler/vim-angry'

" adds `%`, `[aigz[]]%`
PlugMemoize 'andymass/vim-matchup'

" adds a `iv` and `av` motion for variable segments (camel or snake case)
PlugMemoize 'Julian/vim-textobj-variable-segment'

" adds a `iq` and `aq` motion to cover `[ai][`'"]`
PlugMemoize 'beloglazov/vim-textobj-quotes'

" adds highlighting to indicate indent level
PlugMemoize 'nathanaelkane/vim-indent-guides'

" `sj` to join and `sk` to split - supports various ruby awesomeness
PlugMemoize 'AndrewRadev/splitjoin.vim'

" `cx<motion>` to mark an item for exchange, do it again (supports `.`) and
" items are exchanged
PlugMemoize 'tommcdo/vim-exchange'

" `g<l|L><motion><character|/pattern>` to align by padding left (`l`) or right
" (`L`) of the
PlugMemoize 'tommcdo/vim-lion'

" utilities for editing vimscript
" TODO make this conditional on project directory
PlugMemoize 'tpope/vim-scriptease'

" Command over Completion
PlugMemoize 'neoclide/coc.nvim',
      \ ForModes('nvim'),
      \ {'branch': 'release'}

" For LSP support
" PlugMemoize 'autozimu/LanguageClient-neovim',
"       \ ForModes('vim', 'nvim'), {
"       \ 'branch': 'next',
"       \ 'do': 'bash install.sh',
"       \ }

" provides a concentration writing mode `:Goyo`
PlugMemoize 'junegunn/goyo.vim'

call plug#end()
