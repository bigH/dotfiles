if exists('g:custom_search_utils')
  finish
endif

" required for GetVisualSelectionAsString
execute "source" $DOT_FILES_DIR . "/" . "vim/includes/get_visual_selection.vim"

let g:custom_search_utils = 1

let g:search_data_save = "./.hiren/search_utils_save.vim"

let g:current_star_searches = []
let g:current_star_search_history = [[]]
let g:last_known_manual_search = @/

let g:search_util_log = []

let g:search_highlight_colors = [
      \   'ctermbg=red         ctermfg=black guibg=red         guifg=black',
      \   'ctermbg=yellow      ctermfg=black guibg=yellow      guifg=black',
      \   'ctermbg=green       ctermfg=black guibg=green       guifg=black',
      \   'ctermbg=cyan        ctermfg=black guibg=cyan        guifg=black',
      \   'ctermbg=blue        ctermfg=black guibg=blue        guifg=black',
      \   'ctermbg=magenta     ctermfg=black guibg=magenta     guifg=black',
      \   'ctermbg=darkgrey    ctermfg=black guibg=darkgrey    guifg=black',
      \   'ctermbg=lightgrey   ctermfg=black guibg=lightgrey   guifg=black',
      \   'ctermbg=lightcyan   ctermfg=black guibg=lightcyan   guifg=black',
      \   'ctermbg=lightgreen  ctermfg=black guibg=lightgreen  guifg=black',
      \   'ctermbg=lightyellow ctermfg=black guibg=lightyellow guifg=black',
      \   'ctermbg=lightred    ctermfg=black guibg=lightred    guifg=black',
      \   'ctermbg=brown       ctermfg=black guibg=brown       guifg=black',
    \ ]

let g:current_match_highlight = 'ctermbg=white ctermfg=black guibg=white guifg=black'

let w:current_star_matches = []

function! s:SetupHighlights()
  let idx = 0
  for higlight_config in g:search_highlight_colors
    let highlight_name = "StarPoundSearchIdx" . l:idx
    execute "highlight " . l:highlight_name . " " . g:search_highlight_colors[l:idx]
    let idx = l:idx + 1
  endfor
endfunction

function! s:IsSearchManual()
  let old_search = s:GetCalculatedPattern()
  " preserve manual search for use in rewind
  if l:old_search != @/
    return 1
  else
    return 0
  endif
endfunction

function! s:GetNextSearchTerm(is_visual)
  try
    let search = ''
    if (a:is_visual == 1)
      let search = GetVisualSelectionAsString()
    else
      let search = expand("<cword>")
    endif
    return l:search
  catch /.*/
    echo "Couldn't get next search term"
  endtry
endfunction

function! s:EscapeSearch(search)
  return escape(a:search, '\\/.*$^~[]')
endfunction

function! s:BoundSearch(search)
  return '\<' . a:search . '\>'
endfunction

function! s:GetCalculatedPattern()
  try
    let search_terms = []
    for search_group in g:current_star_searches
      for search_term in l:search_group
        call add(l:search_terms, l:search_term)
      endfor
    endfor
    if len(l:search_terms) >= 2 && l:search_terms[-1] == l:search_terms[-2]
      return '\V\(' . l:search_terms[-1] . '\)'
    elseif len(l:search_terms)
      return '\V\(' . join(l:search_terms, '\|') . '\)'
    else
      return ''
    endif
  catch /.*/
    echo "Couldn't execute new search"
  endtry
endfunction

function! s:KillHighlight()
  if exists('w:current_star_matches')
    for match_info in w:current_star_matches
      try
        call matchdelete(l:match_info)
      catch /.*/
      endtry
    endfor
  endif
endfunction

function! s:KillHighlightAll()
  let current_window = winnr()
  windo call s:KillHighlight()
  execute current_window . 'wincmd w'
endfunction

function! s:DoFullHighlight()
  let w:current_star_matches = []
  let idx = 0
  for search_group in g:current_star_searches
    if idx < len(g:search_highlight_colors)
      let highlight_name = "StarPoundSearchIdx" . l:idx
      for search_term in l:search_group
        let l:match_id = matchadd(l:highlight_name, l:search_term, 70 + l:idx)
        call add(w:current_star_matches, l:match_id)
        call add(g:search_util_log, l:idx . ' / ' . l:search_term)
        call add(g:search_util_log, l:highlight_name . ' (' . l:match_id . ')')
      endfor
    endif
    let idx = l:idx + 1
  endfor
endfunction

function! s:ReHighlightWindow()
  call s:KillHighlight()
  call s:DoFullHighlight()
endfunction

function! s:ReHighlightAll()
  let current_window = winnr()
  windo call s:ReHighlightWindow()
  execute current_window . 'wincmd w'
endfunction

function! s:HighlightNewWindow()
  let w:current_star_matches = []
  call s:DoFullHighlight()
endfunction

function! s:HighlightNewTermInWindow(search_term)
  if !exists('w:current_star_matches')
    let w:current_star_matches = []
  endif

  let idx = len(g:current_star_searches) - 1
  let highlight_name = "StarPoundSearchIdx" . l:idx

  call add(w:current_star_matches, matchadd(l:highlight_name, a:search_term, 70 + l:idx))
endfunction

function! s:HighlightNewTerm(search_term)
  let current_window = winnr()
  windo call s:HighlightNewTermInWindow(a:search_term)
  execute current_window . 'wincmd w'
endfunction

function! s:PopHighlightInWindow()
  if !exists('w:current_star_matches')
    let w:current_star_matches = []
  endif

  if len(w:current_star_matches) == 0
    add(g:search_util_log, "ERROR: couldn't pop ".winnr()
  else
    let match_info = w:current_star_matches[-1]
    call matchdelete(l:match_info)
    call remove(w:current_star_matches, -1)
  endif
endfunction

function! s:PopHighlight()
  let current_window = winnr()
  windo call s:PopHighlightInWindow()
  execute current_window . 'wincmd w'
endfunction

function! s:DoPushSearch(search_term, is_new)
  let is_last_search_manual = s:IsSearchManual()

  let search_register_pre = @/

  if a:is_new || len(g:current_star_searches) == 0
    call add(g:current_star_searches, [a:search_term])
  else
    call add(g:current_star_searches[-1], a:search_term)
  endif
  call add(g:current_star_search_history, deepcopy(g:current_star_searches))

  let @/ = s:GetCalculatedPattern()

  if (l:is_last_search_manual)
    let g:last_known_manual_search = l:search_register_pre
    call s:ReHighlightAll()
  else
    call s:HighlightNewTerm(a:search_term)
  endif

  echo '-> ' . string(reverse(deepcopy(g:current_star_searches)))
endfunction

function! s:PopSearch()
  call s:PopHighlight()
  if len(g:current_star_searches)
    if len(g:current_star_searches[-1]) > 1
      call remove(g:current_star_searches[-1], -1)
    else
      call remove(g:current_star_searches, -1)
    endif
    call remove(g:current_star_search_history, -1)
    let @/ = s:GetCalculatedPattern()
  endif

  echo '<- ' . string(reverse(deepcopy(g:current_star_searches)))
endfunction

function! PushBoundedSearch(is_visual, is_new)
  let l:search_term = s:GetNextSearchTerm(a:is_visual)
  let l:prepared = s:BoundSearch(s:EscapeSearch(l:search_term))
  call s:DoPushSearch(l:prepared, a:is_new)
endfunction

function! PushUnboundedSearch(is_visual, is_new)
  let l:search_term = s:GetNextSearchTerm(a:is_visual)
  let l:prepared = s:EscapeSearch(l:search_term)
  call s:DoPushSearch(l:prepared, a:is_new)
endfunction

function! RewindCurrentSearchHistory()
  if (s:IsSearchManual())
    let g:last_known_manual_search = @/
    let @/ = s:GetCalculatedPattern()
    call s:ReHighlightAll()
  elseif (len(g:current_star_searches) == 0)
    let @/ = g:last_known_manual_search
  else
    call s:PopSearch()
  endif
endfunction

function! s:ClearHighlightsIfSearched(cancelled, cmdtype)
  if (!a:cancelled && a:cmdtype == '/')
    call s:KillHighlightAll()
  endif
endfunction

function! s:LoadSearchOnEnter()
  if filereadable(g:search_data_save)
    exec "source" g:search_data_save
  endif
  if (len(g:current_star_searches) > 0)
    let @/ = s:GetCalculatedPattern()
  endif
endfunction

function! s:SaveSearchOnExit()
  call system('mkdir -p "./.hiren"')
  if filewritable(g:search_data_save)
    let out = ["let g:current_star_searches = " . string(g:current_star_searches),
             \ "let g:current_star_search_history = " . string(g:current_star_search_history)]
    call writefile(out, g:search_data_save, 'b')
  endif
  if (@/ == s:GetCalculatedPattern())
    let @/ = g:last_known_manual_search
  endif
endfunction

function! SearchUtilsClearCurrent()
  if exists('w:current_match_metadata')
    call matchdelete(w:current_match_metadata)
  end
endfunction

function! SearchUtilsHighlightCurrent()
  let [bufnum, row, column, ignore] = getpos('.')
  exe "highlight SearchCurrentResult " . g:current_match_highlight
  if exists('w:current_match_metadata')
    try
      call matchdelete(w:current_match_metadata)
    catch /.*/
    endtry
  end
  let matchlen = strlen(matchstr(strpart(getline('.'),column-1),@/))
  let target_pat = '\c\%#\%('.@/.'\)'
  let w:current_match_metadata = matchadd('SearchCurrentResult', target_pat, 101)
endfunction

vnoremap <silent> <Plug>(VisualPushBoundedSearch) :<C-U>call PushBoundedSearch(1, 0)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>
vnoremap <silent> <Plug>(VisualPushUnboundedSearch) :<C-U>call PushUnboundedSearch(1, 0)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

vnoremap <silent> <Plug>(VisualPushNewBoundedSearch) :<C-U>call PushBoundedSearch(1, 1)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>
vnoremap <silent> <Plug>(VisualPushNewUnboundedSearch) :<C-U>call PushUnboundedSearch(1, 1)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

nnoremap <silent> <Plug>(PushBoundedSearch) :<C-U>call PushBoundedSearch(0, 0)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>
nnoremap <silent> <Plug>(PushUnboundedSearch) :<C-U>call PushUnboundedSearch(0, 0)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

nnoremap <silent> <Plug>(PushNewBoundedSearch) :<C-U>call PushBoundedSearch(0, 1)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>
nnoremap <silent> <Plug>(PushNewUnboundedSearch) :<C-U>call PushUnboundedSearch(0, 1)<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

nnoremap <silent> <Plug>(RewindCurrentSearchHistory) :<C-U>call RewindCurrentSearchHistory()<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>
vnoremap <silent> <Plug>(RewindCurrentSearchHistory) :<C-U>call RewindCurrentSearchHistory()<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

augroup ReHighlightAutomation
  autocmd VimEnter * call s:SetupHighlights()
  autocmd VimEnter * call s:LoadSearchOnEnter()
  autocmd VimEnter * call s:ReHighlightAll()

  autocmd VimLeavePre * call s:SaveSearchOnExit()

  autocmd CmdlineLeave * call s:ClearHighlightsIfSearched(v:event.abort, v:event.cmdtype)

  " TODO this actually doesn't work because `winnr()` is not the same as the
  " new window being created.
  autocmd WinNew * call s:HighlightNewWindow()
  autocmd ColorScheme * call s:ReHighlightAll()

  autocmd CursorMoved * call SearchUtilsHighlightCurrent()
  autocmd WinEnter * call SearchUtilsHighlightCurrent()
  autocmd WinLeave * call SearchUtilsClearCurrent()
augroup end

if !exists('g:search_utils_rescroll') || g:search_utils_rescroll == 'no'
  nnoremap <silent> <Plug>(highlight-and-focus-next) n:call SearchUtilsHighlightCurrent()<CR>
  nnoremap <silent> <Plug>(highlight-and-focus-prev) N:call SearchUtilsHighlightCurrent()<CR>
elseif g:search_utils_rescroll == 'directional'
  nnoremap <silent> <Plug>(highlight-and-focus-next) nzb:call SearchUtilsHighlightCurrent()<CR>
  nnoremap <silent> <Plug>(highlight-and-focus-prev) Nzt:call SearchUtilsHighlightCurrent()<CR>
elseif g:search_utils_rescroll == 'center'
  nnoremap <silent> <Plug>(highlight-and-focus-next) nzz:call SearchUtilsHighlightCurrent()<CR>
  nnoremap <silent> <Plug>(highlight-and-focus-prev) Nzz:call SearchUtilsHighlightCurrent()<CR>
endif

if !exists('g:search_utils_no_mappings') || g:search_utils_no_mappings == 0
  if !exists('g:search_utils_no_highlight_current') || g:search_utils_no_highlight_current == 0
    nmap <silent> n <Plug>(highlight-and-focus-next)
    nmap <silent> N <Plug>(highlight-and-focus-prev)
  endif

  if !exists('g:search_utils_no_visual_mappings') || g:search_utils_no_visual_mappings == 0
    vmap <silent> * <Plug>(VisualPushNewUnboundedSearch)
    vmap <silent> # <Plug>(VisualPushUnboundedSearch)
  endif

  if !exists('g:search_utils_no_visual_g_mappings') || g:search_utils_no_visual_g_mappings == 0
    vmap <silent> g* <Plug>(VisualPushNewBoundedSearch)
    vmap <silent> g# <Plug>(VisualPushBoundedSearch)
  endif

  if !exists('g:search_utils_no_normal_mappings') || g:search_utils_no_normal_mappings == 0
    nmap <silent> * <Plug>(PushNewBoundedSearch)
    nmap <silent> # <Plug>(PushBoundedSearch)
  endif

  if !exists('g:search_utils_no_normal_g_mappings') || g:search_utils_no_normal_g_mappings == 0
    nmap <silent> g* <Plug>(PushNewUnboundedSearch)
    nmap <silent> g# <Plug>(PushUnboundedSearch)
  endif

  if !exists('g:search_utils_no_rewind_mappings') || g:search_utils_no_rewind_mappings == 0
    nmap <BS> <Plug>(RewindCurrentSearchHistory)
  endif
endif
