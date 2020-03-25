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
  nmap <C-\> :<C-U>vsplit<CR><Plug>(fzf_tags)
endif

" -- fzf --

if IsPluginLoaded('junegunn/fzf', 'junegunn/fzf.vim')
  " Using floating windows of Neovim to start fzf
  try
    " verify that we can make windows
    let Throwaway = function('nvim_open_win')

    function! FloatingFZF(width, height, border_highlight)
      function! s:create_float(hl, opts)
        let buf = nvim_create_buf(v:false, v:true)
        let opts = extend({'relative': 'editor', 'style': 'minimal'}, a:opts)
        let win = nvim_open_win(buf, v:true, opts)
        call setwinvar(win, '&winhighlight', 'NormalFloat:'.a:hl)
        call setwinvar(win, '&colorcolumn', '')
        return buf
      endfunction

      " Size and position
      let width = float2nr(&columns * a:width)
      let height = float2nr(&lines * a:height)
      let row = float2nr((&lines - height) / 2)
      let col = float2nr((&columns - width) / 2)

      " Border
      let top = '╭' . repeat('─', width - 2) . '╮'
      let mid = '│' . repeat(' ', width - 2) . '│'
      let bot = '╰' . repeat('─', width - 2) . '╯'
      let border = [top] + repeat([mid], height - 2) + [bot]

      " Draw frame
      let s:frame = s:create_float(a:border_highlight, {'row': row, 'col': col, 'width': width, 'height': height})
      call nvim_buf_set_lines(s:frame, 0, -1, v:true, border)

      " Draw viewport
      call s:create_float('Normal', {'row': row + 1, 'col': col + 2, 'width': width - 4, 'height': height - 2})
      autocmd BufWipeout <buffer> execute 'bwipeout' s:frame
    endfunction

    let g:fzf_layout = { 'window': 'call FloatingFZF(0.9, 0.9, "Comment")' }
  catch /.*/
    echo "Floating FZF Setup abanadoned"
  endtry

  " Other small things
  if has('nvim') && !exists('g:fzf_layout')
    autocmd! FileType fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler nohlsearch
          \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler hlsearch
  endif

  " Customize fzf to use tabs for <Enter>
  let g:fzf_action = {
        \ '?':      'toggle-preview',
        \ 'change': 'top',
        \ 'ctrl-s': 'toggle-sort',
        \ 'ctrl-e': 'preview-down',
        \ 'ctrl-y': 'preview-up',
        \ 'ctrl-m': 'e!',
        \ 'ctrl-o': 'e!',
        \ 'ctrl-t': 'tabedit',
        \ 'ctrl-h': 'split',
        \ 'ctrl-v': 'vsplit' }

  " Open old-files
  command! RecentFiles call fzf#run({
        \  'source':  filter(v:oldfiles, 'v:val =~ getcwd() && filereadable(v:val)'),
        \  'sink':    'e',
        \  'options': '-m -x +s',
        \  'down':    '40%'})

  " TODO make this work
  function! FzfFindInDirectoryfunc()
    wincmd l
    call fzf#vim#grep(
          \   'rg --column --line-number --no-heading --color=always --smart-case '.
          \   shellescape(<q-args>).' ',
          \   0,
          \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] })
  endfunction

  function! GetFzfSetup(fullscreen)
    if a:fullscreen
      return 'down:50%'
    else
      let height = &lines * 1.0
      let width = &columns * 1.0
      let ratio = width / height
      if ratio < 2 && height > 100
        return 'down:70%'
      elseif ratio < 2 && height > 70
        return 'down:55%'
      elseif ratio < 2
        return 'down:45%'
      elseif width > 250
        return 'right:60%'
      elseif width > 220
        return 'right:55%'
      else
        return 'right:50%'
      endif
    end
  endfunction

  let g:fzf_config_for_rg = { 'options' : [
        \                       '--no-hscroll',
        \                       '--bind', 'ctrl-s:toggle-sort',
        \                   ] }

  " Rg with preview and visual yank
  command! -bang -nargs=* RgVisual
        \ call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case '.
        \       (<bang>0 ? '--no-ignore --hidden ' : '').
        \       '"'.GetVisualSelectionAsString().'"',
        \   1,
        \   <bang>0 ? fzf#vim#with_preview(g:fzf_config_for_rg, GetFzfSetup(1))
        \           : fzf#vim#with_preview(g:fzf_config_for_rg, GetFzfSetup(0), '?'),
        \   <bang>0)

  " Rg with preview
  command! -bang -nargs=* Rg
        \ call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case '.
        \     shellescape(<q-args>),
        \   1,
        \   <bang>0 ? fzf#vim#with_preview(g:fzf_config_for_rg, GetFzfSetup(1))
        \           : fzf#vim#with_preview(g:fzf_config_for_rg, GetFzfSetup(0), '?'),
        \   <bang>0)

  function! OptionsForFiles(additional_fd_opts)
    return {
        \    'source': 'fd --hidden --color=always ' . a:additional_fd_opts,
        \    'options': [
        \      '--ansi',
        \      '--layout=reverse',
        \      '--bind',
        \      'ctrl-s:toggle-sort',
        \      '--info=default'
        \    ]
        \  }
  endfunction

  " Files with preview
  command! -bang -nargs=? -complete=dir Files
        \ call fzf#vim#files(<q-args>,
        \   <bang>0 ? fzf#vim#with_preview(OptionsForFiles('--no-ignore --exclude ".git/"'), GetFzfSetup(1), '?')
        \           : fzf#vim#with_preview(OptionsForFiles(''), GetFzfSetup(0)),
        \   <bang>0)

  function! DoNothingSink(lines)
  endfunction

  " File History with Preview
  command! -bar -bang FileHistoryDiff
        \ call fzf#vim#buffer_commits(
        \   {
        \     'options': [
        \       '--no-sort', '--preview',
        \       <bang>0 ? ('echo {} | ' .
        \                  'grep -o "[a-f0-9]\{7,\}" | ' .
        \                  'head -1 | ' .
        \                  'xargs -I COMMIT_SHA git show -W COMMIT_SHA:"' . expand('%') . '" | ' .
        \                  'bat -p --color always -l ' . &l:filetype)
        \               : ('echo {} | ' .
        \                  'grep -o "[a-f0-9]\{7,\}" | ' .
        \                  'head -1 | ' .
        \                  'xargs -I COMMIT_SHA git diff COMMIT_SHA~ COMMIT_SHA -- ' . expand('%') . ' | ' .
        \                  'diff-so-fancy')
        \     ],
        \     'sink*': function('DoNothingSink')
        \   }, 1)

  " File History for a Selection
  command! -bar -bang VisualFileHistoryDiff
        \ call fzf#vim#commits(
        \   {
        \     'source':
        \       <bang>0 ? ('git log --fixed-strings -L ":' . GetVisualSelectionAsString(). ':' . expand('%') . '" --color=never "--format=%C(auto)%h%d %s %C(green)%cr" | grep "^[a-z0-9]\{7,\}\s\S.*$" --color=never')
        \               : ('git log --fixed-strings -S "' . GetVisualSelectionAsString(). '" --color=always "--format=%C(auto)%h%d %s %C(green)%cr"'),
        \     'options': [
        \       '--preview',
        \       <bang>0 ? ('echo {} | ' .
        \                  'grep -o "[a-f0-9]\{7,\}" | ' .
        \                  'head -1 | ' .
        \                  'xargs -I COMMIT_SHA git log -W --color=always --fixed-strings -L ":' . GetVisualSelectionAsString(). ':' . expand('%') . '" COMMIT_SHA -1')
        \               : ('echo {} | ' .
        \                  'grep -o "[a-f0-9]\{7,\}" | ' .
        \                  'head -1 | ' .
        \                  'xargs -I COMMIT_SHA git diff COMMIT_SHA~ COMMIT_SHA | ' .
        \                  'diff-so-fancy')
        \     ],
        \     'sink*': function('DoNothingSink')
        \   }, 1)

  " Map `\f` to FZF search all files with Rg full screen
  nmap <silent> <leader>F :<C-U>Rg!<CR>
  nmap <silent> <leader>f :<C-U>Rg<CR>
  " Use selected text to prepopulate
  vmap <silent> <leader>F :<C-U>RgVisual!<CR>
  vmap <silent> <leader>f :<C-U>RgVisual<CR>

  " Map `\h` to FZF search open files
  nmap <silent> <leader>H :<C-U>FileHistory!<CR>
  nmap <silent> <leader>h :<C-U>FileHistory<CR>
  " Use selected text to search diff
  vmap <silent> <leader>H :<C-U>VisualFileHistoryDiff!<CR>
  vmap <silent> <leader>h :<C-U>VisualFileHistoryDiff<CR>

  " Map `\t` to FZF tag finder - gets overriden below by other bindings
  nmap <silent> <leader>t :<C-U>Tags<CR>

  " Map `\e` to FZF file lister
  nmap <silent> <leader>E :<C-U>Files!<CR>
  nmap <silent> <leader>e :<C-U>Files<CR>

  " Map `\o` to FZF file lister
  nmap <silent> <leader>O :<C-U>RecentFiles<CR>

  " Map `\O` to FZF git file lister
  nmap <silent> <leader>o :<C-U>GFiles?<CR>

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
  \ }

  " Use `bundle`
  let g:ale_ruby_rubocop_executable = 'bundle'

  " Don't lint while typing
  let g:ale_lint_on_text_changed = 'never'

  " Show the full list of lint errors
  " let g:ale_open_list = 1

  " Enable `ale` airline stuff
  let g:airline#extensions#ale#enabled = 1

  " replace git things
  let g:airline_section_b = '%t'
  let g:airline_section_c = ''

  " Fix on Save (Sucks on Rubocop)
  let g:ale_fix_on_save = 1
endif

" -- nerd-tree --

if IsPluginLoaded('scrooloose/nerdtree')
  " Refresh NERDTree upon return to ViM
  augroup NERDTree
    " TODO this can be slow, so maybe not always on?
    " autocmd FocusGained * NERDTreeRefreshRoot
  augroup END

  " Set it to not show `? for help`
  let NERDTreeMinimalUI = 1

  " Auto-remove buffer of file just deleted
  let NERDTreeAutoDeleteBuffer = 1
endif

" -- airline --

if IsPluginLoaded('vim-airline/vim-airline')
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffers_label = ''
  let g:airline#extensions#tabline#tabs_label = ''
endif

" -- vim-textobj-user --

if IsPluginLoaded('kana/vim-textobj-user')
  exec "source" $DOT_FILES_DIR . "/vim/custom/text_objects.vim"
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
  xmap gc <Plug>Commentary

  nmap gc <Plug>Commentary
  omap gc <Plug>Commentary

  " `gcc` !== `gcgc` and both work
  nmap gcc <Plug>Commentary<Plug>(line-object)
endif

" -- splitjoin.vim --

if IsPluginLoaded('AndrewRadev/splitjoin.vim')
  let g:splitjoin_curly_brace_padding = 0
  let g:splitjoin_trailing_comma = 1

  let g:splitjoin_ruby_hanging_args = 0
  let g:splitjoin_ruby_curly_braces = 0
  let g:splitjoin_ruby_options_as_arguments = 1

  " `splitjoin` docs say to do this.
  let g:splitjoin_split_mapping = ''
  let g:splitjoin_join_mapping = ''

  nmap sj :<C-U>SplitjoinSplit<cr>
  nmap sk :<C-U>SplitjoinJoin<cr>
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
  function! SmartNERDTree()
    if @% == ""
      NERDTreeToggle
    else
      NERDTreeFind
    endif
  endfun

  nnoremap <silent> <F1> :<C-U>call SmartNERDTree()<CR>
  inoremap <silent> <F1> <Esc>:<C-U>call SmartNERDTree()<CR>a
endif

" F2 opens Tagbar
if IsPluginLoaded('majutsushi/tagbar')
  nmap <silent> <F2> :<C-U>TagbarOpen<CR>
  imap <silent> <F2> <Esc>:<C-U>TagbarOpen<CR>a
endif

" F3 closes Tagbar & NERDTree
if IsPluginLoaded('scrooloose/nerdtree', 'majutsushi/tagbar')
  nmap <silent> <F3> :<C-U>TagbarClose<CR>:NERDTreeClose<CR>:pclose<CR>:cclose<CR>:lclose<CR>
  imap <silent> <F3> <Esc>:<C-U>TagbarClose<CR>:NERDTreeClose<CR>:pclose<CR>:cclose<CR>:lclose<CR>a
endif

" F4 and <leader>b
if IsPluginLoaded('junegunn/fzf', 'junegunn/fzf.vim')
  nmap <silent> <F4> :<C-U>Buffers<CR>
  imap <silent> <F4> <Esc>:<C-U>Buffers<CR>

  nmap <silent> <leader>b <Esc>:<C-U>Buffers<CR>
endif

" functions for use below to make NERDTree switch windows in the editor region
if IsPluginLoaded('scrooloose/nerdtree')
  function! NERDClose()
    NERDTreeClose
  endfunction

  function! NERDSpace()
    execute 'normal' '<Leader>'
  endfunction

  function! NERDEnterCommand()
    execute 'normal!' ':'
  endfunction

  function! NERDBPrev()
    execute 'wincmd' 'l'
    execute 'bprev'
  endfunction

  function! NERDBFirst()
    execute 'wincmd' 'l'
    execute 'bfirst'
  endfunction

  function! NERDBNext()
    execute 'wincmd' 'l'
    execute 'bnext'
  endfunction

  function! NERDBLast()
    execute 'wincmd' 'l'
    execute 'blast'
  endfunction

  " L/H/C-H/C-L in NERDTree
  augroup NERDTree
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': 'Q'       , 'callback': 'NERDClose'       , 'override': 1 })
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<Space>' , 'callback': 'NERDSpace'       , 'override': 1 })
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<CR>'    , 'callback': 'NERDEnterCommand', 'override': 1 })
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': 'H'       , 'callback': 'NERDBPrev'       , 'override': 1 })
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<C-H>'   , 'callback': 'NERDBFirst'      , 'override': 1 })
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': 'L'       , 'callback': 'NERDBNext'       , 'override': 1 })
    autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<C-L>'   , 'callback': 'NERDBLast'       , 'override': 1 })
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

  " highlight
  autocmd VimEnter,Colorscheme * highlight IndentGuidesOdd ctermbg=black guibg=black
  autocmd VimEnter,Colorscheme * highlight IndentGuidesEven ctermbg=NONE guibg=NONE
endif

" -- vim-scala --

if IsPluginLoaded('derekwyatt/vim-scala')
  au BufRead,BufNewFile *.sbt set filetype=scala
endif

" -- vim-autoclose --

if IsPluginLoaded('Townk/vim-autoclose')
  au BufRead,BufNewFile *.rb let g:AutoClosePairs_add = "|"
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
    au FileType ruby nnoremap <silent> <buffer> <Leader>T :call LanguageClient#textDocument_typeDefinition()<CR>
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
  nmap <silent> <leader>coe <Plug>(coc-diagnostic-prev)
  nmap <silent> <leader>cne <Plug>(coc-diagnostic-prev)
  nmap <silent> <leader>cPe <Plug>(coc-diagnostic-prev)
  nmap <silent> <leader>cpe <Plug>(coc-diagnostic-next)
  nmap <silent> <leader>cNe <Plug>(coc-diagnostic-next)

  " Gotos
  nmap <silent> <Leader>d <Plug>(coc-definition)
  nmap <silent> <Leader>i <Plug>(coc-implementation)
  nmap <silent> <Leader>r <Plug>(coc-references)
  " overrides fzf `:Tags`
  nmap <silent> <Leader>t <Plug>(coc-type-definition)
endif

" -- Colorizer --

if IsPluginLoaded('chrisbra/Colorizer')
  " TODO turn on when appropriate
endif

" -- rainbow-parentheses --

if IsPluginLoaded('luochen1990/rainbow')
  " always on
  let g:rainbow_active = 1
endif

" -- vim-diminactive --

if IsPluginLoaded('blueyed/vim-diminactive')
  let g:diminactive_enable_focus = 1
endif

" -- vim-bufkill --

if IsPluginLoaded('qpkorr/vim-bufkill')
  nnoremap <silent> Q :<C-U>BD<CR>
  let g:BufKillActionWhenBufferDisplayedInAnotherWindow = 'kill'
  let g:BufKillFunctionSelectingValidBuffersToDisplay = 'auto'
  let g:BufKillActionWhenModifiedFileToBeKilled = 'fail'
  let g:BufKillCreateMappings = 0
endif

" -- golden-ratio --

" if IsPluginLoaded('roman/golden-ratio')
"   let g:golden_ratio_autocommand=0
" endif
