if exists('g:plugin_configs')
  finish
endif
let g:plugin_configs = 1


"{{{ Plugin Configurations

" -- fzf-tags --

if IsPluginLoaded('junegunn/fzf', 'junegunn/fzf.vim', 'zackhsi/fzf-tags')
  " Replace <C-]> with fuzzy tag finder when more than one occurence of tag
  nmap <silent> <C-]> <Plug>(fzf_tags)

  " Map <C-\> to do this with vsplit
  nmap <C-\> :vsplit<CR><Plug>(fzf_tags)
endif

" -- fzf --

if IsPluginLoaded('junegunn/fzf', 'junegunn/fzf.vim', 'yuki-ycino/fzf-preview.vim')
  " use `bat`
  let g:fzf_preview_command = 'bat -p --color always {-1}'

endif

" -- fzf --

if IsPluginLoaded('junegunn/fzf', 'junegunn/fzf.vim')
  " Customize fzf to use tabs for <Enter>
  " TODO many of these don't work
  let g:fzf_action = {
        \ 'ctrl-m': 'e!',
        \ 'ctrl-o': 'e!',
        \ 'ctrl-t': 'tabedit',
        \ 'ctrl-h': 'split',
        \ 'ctrl-v': 'vsplit' }

  " Open old-files
  command! RecentFiles call fzf#run({
        \  'source':  v:oldfiles,
        \  'sink':    'e',
        \  'options': '-m -x +s',
        \  'down':    '40%'})

  " TODO make this work
  func! FzfFindInDirectoryfunc()
    wincmd l
    call fzf#vim#grep(
          \   'rg --column --line-number --no-heading --color=always --smart-case '.
          \   shellescape(<q-args>).' ',
          \   0,
          \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] })
  endfunc

  " Augmenting Ag command using fzf#vim#with_preview function
  "   * fzf#vim#with_preview([[options], [preview window], [toggle keys...]])
  "     * For syntax-highlighting, Ruby and any of the following tools are required:
  "       - Bat: https://github.com/sharkdp/bat
  "       - Highlight: http://www.andre-simon.de/doku/highlight/en/highlight.php
  "       - CodeRay: http://coderay.rubychan.de/
  "       - Rouge: https://github.com/jneen/rouge
  "
  "   :Ag  - Start fzf with hidden preview window that can be enabled with "?" key
  "   :Ag! - Start fzf in fullscreen and display the preview window above
  command! -bang -nargs=* Ag
        \ call fzf#vim#ag(<q-args>,
        \                 <bang>0 ? fzf#vim#with_preview('up:60%')
        \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
        \                 <bang>0)

  " Similarly, we can apply it to fzf#vim#grep. To use ripgrep instead of ag:
  command! -bang -nargs=* Rg
        \ call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
        \   <bang>0 ? fzf#vim#with_preview('up:60%')
        \           : fzf#vim#with_preview('right:50%:hidden', '?'),
        \   <bang>0)

  " Map `\f` to FZF search all files with Rg
  nmap <silent> <leader>f :Rg<CR>
  " Map `\F` to FZF search open files
  nmap <silent> <leader>F :Lines<CR>

  " Map `\t` to FZF tag finder
  nmap <silent> <leader>t :Tags<CR>

  " Map `\e` to FZF file lister
  nmap <silent> <leader>e :Files<CR>
  nmap <silent> <leader>E :Files<CR>

  " Map `\o` to FZF file lister
  nmap <silent> <leader>O :RecentFiles<CR>

  " Map `\O` to FZF git file lister
  nmap <silent> <leader>o :GFiles?<CR>

  " Set history directory
  let g:fzf_history_dir = '~/.local/share/fzf-history'
endif

" -- fzf + NERDTree --

if IsPluginLoaded('junegunn/fzf', 'junegunn/fzf.vim', 'scrooloose/nerdtree')
  " TODO doesn't really work
  command! FzfFindInDirectory call FzfFindInDirectoryFunction()

  " Make `\f` search in a given directory using fzf#run
  augroup NERDTree
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<Leader>f', 'callback': 'FzfFindInDirectoryFunction', 'override': 1 })
  augroup END
endif

" -- ale --

if IsPluginLoaded('dense-analysis/ale')
  " Symbols to use
  let g:ale_sign_error = '✘'
  let g:ale_sign_warning = '▲'

  " Execution configs
  let g:ale_linters = {}
  let g:ale_linters['ruby'] = ['rubocop']
  let g:ale_linters['javascript'] = ['prettier', 'eslint']
  let g:ale_linters['haskell'] = ['stack-ghc-mod', 'hlint']

  let g:ale_fixers = {
  \   'ruby': ['rubocop'],
  \   'javascript': ['prettier'],
  \   'typescript': ['prettier'],
  \   'typescriptreact': ['prettier'],
  \   'css': ['prettier'],
  \}

  " Use `bundle`
  let g:ale_ruby_rubocop_executable = 'bundle'

  " Don't lint while typing
  let g:ale_lint_on_text_changed = 'never'

  " Show the full list of lint errors
  " let g:ale_open_list = 1

  " Enable `ale` airline stuff
  let g:airline#extensions#ale#enabled = 1

  " Fix on Save (Sucks on Rubocop)
  let g:ale_fix_on_save = 1
endif

" -- nerd-tree --

if IsPluginLoaded('scrooloose/nerdtree')
  " Set it to not show `? for help`
  let NERDTreeMinimalUI = 1

  " Auto-remove buffer of file just deleted
  let NERDTreeAutoDeleteBuffer = 1
endif

" -- airline --

if IsPluginLoaded('vim-airline/vim-airline')
  " TODO go back to tabs
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffers_label = ''
  let g:airline#extensions#tabline#tabs_label = ''
endif

" -- vim-textobj-user --

if IsPluginLoaded('kana/vim-textobj-user')
  exec "source" $DOT_FILES_DIR . "/vim/custom/text_objects.vimrc"
endif

" -- vim-angry [textobj] --

if IsPluginLoaded('b4winckler/vim-angry')
  let g:angry_disable_maps = 1

  vmap <silent> a, <Plug>AngryOuterPrefix
  omap <silent> a, <Plug>AngryOuterPrefix
  vmap <silent> i, <Plug>AngryInnerPrefix
  omap <silent> i, <Plug>AngryInnerPrefix

  " TODO keep or not
  " vmap <silent> aA <Plug>AngryOuterSuffix
  " omap <silent> aA <Plug>AngryOuterSuffix
  " vmap <silent> iA <Plug>AngryInnerSuffix
  " omap <silent> iA <Plug>AngryInnerSuffix
end

" -- vim-surround --

if IsPluginLoaded('tpope/vim-surround')
  autocmd FileType ruby let b:surround_{char2nr("-")} = "do \r end"
  autocmd FileType ruby let b:surround_{char2nr("i")} = "if \r end"
  autocmd FileType ruby let b:surround_{char2nr("u")} = "unless \r end"
  autocmd FileType ruby let b:surround_{char2nr("b")} = "begin \r end"

  let g:surround_no_mappings = 1
  let g:surround_indent = 1

  nmap ds <Plug>Dsurround
  nmap cs <Plug>Csurround
  nmap cS <Plug>CSurround
  nmap s  <Plug>Ysurround
  nmap S  <Plug>YSurround
  nmap ss <Plug>Yssurround
  nmap Ss <Plug>YSsurround
  nmap SS <Plug>YSsurround
  xmap s  <Plug>VSurround
  xmap S  <Plug>VgSurround
endif

" -- vim-commentary --

if IsPluginLoaded('tpope/vim-commentary')
  " TODO I don't like this because in visual mode, `c` now waits to see if `m`
  " is provided
  xmap cm <Plug>Commentary
  nmap cm <Plug>Commentary
  nmap cmcm <Plug>Commentary<Plug>Commentary
  " Don't like the operator-pending mapping (though it's easy to uncomment
  " omap cm <Plug>Commentary
endif

" -- splitjoin.vim --

if IsPluginLoaded('AndrewRadev/splitjoin.vim')
  let g:splitjoin_curly_brace_padding = 0
  let g:splitjoin_trailing_comma = 1

  let g:splitjoin_ruby_hanging_args = 0
  let g:splitjoin_ruby_curly_braces = 0
  let g:splitjoin_ruby_options_as_arguments = 1

  " `splitjoin` docs say to do this. nbd.
  let g:splitjoin_split_mapping = ''
  let g:splitjoin_join_mapping = ''

  nmap sj :SplitjoinSplit<cr>
  nmap sk :SplitjoinJoin<cr>
endif

" -- tagbar --

if IsPluginLoaded('majutsushi/tagbar')
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
endif

" -- vim-ruby --

if IsPluginLoaded('vim-ruby/vim-ruby')
  " access modifiers align with definitions
  let g:ruby_indent_access_modifier_style = 'normal'

  " indent blocks properly
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
end

" -- IDE Feel --

" F1 opens NERDTree
if IsPluginLoaded('scrooloose/nerdtree')
  nmap <silent> <F1> :NERDTreeFind<CR>
  imap <silent> <F1> <Esc>:NERDTreeFind<CR>a
endif

" F2 opens Tagbar
if IsPluginLoaded('majutsushi/tagbar')
  nmap <silent> <F2> :TagbarOpen<CR>
  imap <silent> <F2> <Esc>:TagbarOpen<CR>a
endif

" F3 closes Tagbar & NERDTree
if IsPluginLoaded('scrooloose/nerdtree', 'majutsushi/tagbar')
  nmap <silent> <F3> :TagbarClose<CR>:NERDTreeClose<CR>:pclose<CR>:cclose<CR>:lclose<CR>
  imap <silent> <F3> <Esc>:TagbarClose<CR>:NERDTreeClose<CR>:pclose<CR>:cclose<CR>:lclose<CR>a
endif

" F4 and <leader>b
if IsPluginLoaded('junegunn/fzf', 'junegunn/fzf.vim')
  nmap <silent> <F4> :Buffers<CR>
  nmap <silent> <leader>b <Esc>:Buffers<CR>
  imap <silent> <F4> <Esc>:Buffers<CR>
endif

" functions for use below to make NERDTree switch windows in the editor region
if IsPluginLoaded('scrooloose/nerdtree')
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
endif

" L/H/C-H/C-L in Tagbar
if IsPluginLoaded('majutsushi/tagbar')
  augroup TagBar
    autocmd!
    autocmd FileType tagbar nnoremap <buffer> H :wincmd h<CR>:bprev<CR>
    autocmd FileType tagbar nnoremap <buffer> <C-H> :wincmd h<CR>:bfirst<CR>
    autocmd FileType tagbar nnoremap <buffer> L :wincmd h<CR>:bnext<CR>
    autocmd FileType tagbar nnoremap <buffer> <C-L> :wincmd h<CR>:blast<CR>
  augroup END
endif

" -- vim-indent-guides --

if IsPluginLoaded('nathanaelkane/vim-indent-guides')
  " enable at start-up
  let g:indent_guides_enable_on_vim_startup = 1

  " configure colors
  let g:indent_guides_auto_colors = 0
  autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=black
  autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=NONE
endif

" -- vim-scala --

if IsPluginLoaded('derekwyatt/vim-scala')
  au BufRead,BufNewFile *.sbt set filetype=scala
endif

" -- vim-autoclose --

if IsPluginLoaded('Townk/vim-autoclose')
  au BufRead,BufNewFile *.rb let g:AutoClosePairs_add = "|"
  au BufRead,BufNewFile todo-*.md let g:AutoClosePairs_del = "[]"
endif

" -- LanguageClient-neovim --

if IsPluginLoaded('autozimu/LanguageClient-neovim')
  let g:LanguageClient_diagnosticsDisplay = {
      \     1: {
      \         "name": "Error",
      \         "texthl": "ALEError",
      \         "signText": "●",
      \         "signTexthl": "gitgutterDelete",
      \         "virtualTexthl": "gitgutterDelete",
      \     },
      \     2: {
      \         "name": "Warning",
      \         "texthl": "ALEWarning",
      \         "signText": "▲",
      \         "signTexthl": "Todo",
      \     },
      \     3: {
      \         "name": "Information",
      \         "texthl": "ALEError",
      \         "signText": "ℹ",
      \         "signTexthl": "gitgutterDelete",
      \     },
      \     4: {
      \         "name": "Hint",
      \         "texthl": "ALEWarning",
      \         "signText": "➤",
      \         "signTexthl": "Todo",
      \     },
      \ }

  let g:LanguageClient_loggingLevel = 'INFO' " Use highest logging level
  let g:LanguageClient_loggingFile = '/tmp/languageclient-neovim.log'

  if !exists('g:LanguageClient_serverCommands')
    let g:LanguageClient_serverCommands = {}
  endif

  let g:LanguageClient_serverCommands.ruby = ['srb', 'tc', '--lsp', '--enable-experimental-lsp-autocomplete', '--debug-log-file=/tmp/sorbet-nvim.log', '-e', '0', '~/.local/share/empty']

  augroup LanguageClientConfigs
    au!
    au FileType ruby nnoremap <silent> <buffer> <C-Space> :call LanguageClient_contextMenu()<CR>
    au FileType ruby nnoremap <silent> <buffer> <Leader>d :call LanguageClient#textDocument_definition()<CR>
    au FileType ruby nnoremap <silent> <buffer> <Leader>t :call LanguageClient#textDocument_hover()<CR>
    au FileType ruby nnoremap <silent> <buffer> K :call LanguageClient#explainErrorAtPoint()<CR>
    au FileType ruby nnoremap <silent> <buffer> <Leader>t :call LanguageClient#textDocument_typeDefinition()<CR>
    au FileType ruby inoremap <silent> <buffer> <C-Space> <C-x><C-o>
  augroup END
endif

" -- vim-exchange --

if IsPluginLoaded('tommcdo/vim-exchange')
  " reindent after exchange
  let g:exchange_indent = 1
endif

" -- coc.nvim --

if IsPluginLoaded('neoclide/coc.nvim')
  " Better display for messages
  set cmdheight=2

  " don't give |ins-completion-menu| messages.
  set shortmess+=c

  " always show signcolumns
  set signcolumn=yes

  " support comments in json
  autocmd FileType json syntax match Comment +\/\/.\+$+

  " Use <C-Space> to trigger
  inoremap <silent><expr> <c-space> coc#refresh()

  " Use K to show documentation in preview window
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Use `[c` and `]c` for navigate diagnostics
  nmap <silent> [c <Plug>(coc-diagnostic-prev)
  nmap <silent> ]c <Plug>(coc-diagnostic-next)

  " Gotos
  nmap <silent> <Leader>d <Plug>(coc-definition)
  nmap <silent> <Leader>i <Plug>(coc-implementation)
  nmap <silent> <Leader>r <Plug>(coc-references)
  " overrides fzf `:Tags`
  nmap <silent> <Leader>t <Plug>(coc-type-definition)
endif

