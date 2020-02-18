if exists('g:custom_search_utils')
  finish
endif

let g:custom_search_utils = 1

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
    " TODO remove the other place where this is happening
    let highlight_name = "StarPoundSearchIdx" . l:idx
    execute "highlight " . l:highlight_name . " " . g:search_highlight_colors[l:idx]
    let idx = l:idx + 1
  endfor
endfunction

" get content of visual selection as string
function! s:GetVisualSelectionAsString()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
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
      let search = s:GetVisualSelectionAsString()
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
    if len(g:current_star_searches) > 0
      if len(g:current_star_searches) > 1 && g:current_star_searches[-1] == g:current_star_searches[-2]
        return '\V\(' . g:current_star_searches[-1] . '\)'
      else
        let l:searches = deepcopy(g:current_star_searches)
        return '\V\(' . join(l:searches, '\|') . '\)'
      endif
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
  let currentWindow = winnr()
  windo call s:KillHighlight()
  execute currentWindow . 'wincmd w'
endfunction

function! s:DoFullHighlight()
  let w:current_star_matches = []
  let idx = 0
  for searchTerm in g:current_star_searches
    if idx < len(g:search_highlight_colors)
      let highlight_name = "StarPoundSearchIdx" . l:idx
      call add(w:current_star_matches, matchadd(l:highlight_name, l:searchTerm, 70 + l:idx))
    endif
    let idx = l:idx + 1
  endfor
endfunction

function! s:ReHighlightWindow()
  call s:KillHighlight()
  call s:DoFullHighlight()
endfunction

function! s:ReHighlightAll()
  let currentWindow = winnr()
  windo call s:ReHighlightWindow()
  execute currentWindow . 'wincmd w'
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
  execute "highlight " . l:highlight_name . " " . g:search_highlight_colors[l:idx]

  call add(w:current_star_matches, matchadd(l:highlight_name, a:search_term, 70 + l:idx))
endfunction

function! s:HighlightNewTerm(search_term)
  let currentWindow = winnr()
  windo call s:HighlightNewTermInWindow(a:search_term)
  execute currentWindow . 'wincmd w'
endfunction

function! s:PopHighlightInWindow()
  if (len(w:current_star_matches) == 0)
    add(g:search_util_log, "ERROR: couldn't pop ".winnr()
  else
    let match_info = w:current_star_matches[-1]
    call matchdelete(l:match_info)
    call remove(w:current_star_matches, -1)
  endif
endfunction

function! s:PopHighlight()
  let currentWindow = winnr()
  windo call s:PopHighlightInWindow()
  execute currentWindow . 'wincmd w'
endfunction

function! s:DoPushSearch(search_term)
  let is_last_search_manual = s:IsSearchManual()

  let search_register_pre = @/

  call add(g:current_star_searches, a:search_term)
  call add(g:current_star_search_history, deepcopy(g:current_star_searches))

  let @/ = s:GetCalculatedPattern()

  if (l:is_last_search_manual)
    let g:last_known_manual_search = l:search_register_pre
    call s:ReHighlightAll()
  else
    call s:HighlightNewTerm(a:search_term)
  endif
endfunction

function! s:PopSearch()
  call s:PopHighlight()
  call remove(g:current_star_searches, -1)
  call remove(g:current_star_search_history, -1)
  let @/ = s:GetCalculatedPattern()
endfunction

function! s:DoPushBoundedSearch(is_visual)
  let l:search_term = s:GetNextSearchTerm(a:is_visual)
  let l:prepared = s:BoundSearch(s:EscapeSearch(l:search_term))
  call s:DoPushSearch(l:prepared)
endfunction

function! s:DoPushUnboundedSearch(is_visual)
  let l:search_term = s:GetNextSearchTerm(a:is_visual)
  let l:prepared = s:EscapeSearch(l:search_term)
  call s:DoPushSearch(l:prepared)
endfunction

function! s:DoRewindCurrentSearchHistory()
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

function! s:SaveSearchOnExit()
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

command! VisualPushBoundedSearch :call s:DoPushBoundedSearch(1)
command! VisualPushUnboundedSearch :call s:DoPushUnboundedSearch(1)

command! PushBoundedSearch :call s:DoPushBoundedSearch(0)
command! PushUnboundedSearch :call s:DoPushUnboundedSearch(0)

command! RewindCurrentSearchHistory :call s:DoRewindCurrentSearchHistory()

vnoremap <silent> <Plug>(VisualPushBoundedSearch) :<C-U>VisualPushBoundedSearch<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>
vnoremap <silent> <Plug>(VisualPushUnboundedSearch) :<C-U>VisualPushUnboundedSearch<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

nnoremap <silent> <Plug>(PushBoundedSearch) :<C-U>PushBoundedSearch<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>
nnoremap <silent> <Plug>(PushUnboundedSearch) :<C-U>PushUnboundedSearch<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

nnoremap <silent> <Plug>(RewindCurrentSearchHistory) :<C-U>RewindCurrentSearchHistory<CR>:set hlsearch<CR>:call SearchUtilsHighlightCurrent()<CR>

augroup ReHighlightAutomation
  autocmd VimEnter * call s:SetupHighlights()
  autocmd VimLeavePre * call s:SaveSearchOnExit()
  autocmd CmdlineLeave * call s:ClearHighlightsIfSearched(v:event.abort, v:event.cmdtype)

  autocmd WinNew * call s:HighlightNewWindow()
  autocmd ColorScheme * call s:ReHighlightAll()

  " TODO move cursor highlight if applicable
  autocmd CursorMoved * call SearchUtilsHighlightCurrent()
  autocmd WinEnter * call SearchUtilsHighlightCurrent()
  autocmd WinLeave * call SearchUtilsClearCurrent()
augroup end

nnoremap <silent> <Plug>(highlight-and-focus-next) nzz:call SearchUtilsHighlightCurrent()<CR>
nnoremap <silent> <Plug>(highlight-and-focus-prev) Nzz:call SearchUtilsHighlightCurrent()<CR>

if !exists('g:search_utils_no_mappings') || g:search_utils_no_mappings == 0
  if !exists('g:search_utils_no_highlight_current') || g:search_utils_no_highlight_current == 0
    nmap <silent> n <Plug>(highlight-and-focus-next)
    nmap <silent> N <Plug>(highlight-and-focus-prev)
  endif

  if !exists('g:search_utils_no_visual_mappings') || g:search_utils_no_visual_mappings == 0
    vmap * <Plug>(VisualPushBoundedSearch)
    vmap # <Plug>(VisualPushUnboundedSearch)
  endif

  if !exists('g:search_utils_no_normal_mappings') || g:search_utils_no_normal_mappings == 0
    nmap * <Plug>(PushBoundedSearch)
    nmap # <Plug>(PushUnboundedSearch)
  endif

  if !exists('g:search_utils_no_rewind_mappings') || g:search_utils_no_rewind_mappings == 0
    nmap <BS> <Plug>(RewindCurrentSearchHistory)
  endif
endif
