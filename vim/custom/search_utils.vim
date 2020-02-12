if exists('g:custom_search_utils')
  " finish
endif

let g:custom_search_utils = 1

let g:current_star_searches = []
let g:current_star_search_history = [[]]
let g:last_known_manual_search = @/

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

let w:current_star_matches = []

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

function! s:GetNextSearchTerm(is_visual)
  try
    let old_search = s:GetCalculatedPattern()
    if l:old_search != @/
      let g:last_known_manual_search = @/
    endif
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

function! s:SearchTermEscape(search)
  return escape(a:search, '\\/.*$^~[]')
endfunction

function! s:GetCalculatedPattern()
  try
    if len(g:current_star_searches) > 0
      let l:searches = deepcopy(g:current_star_searches)
      return '\V\(' . join(l:searches, '\|') . '\)'
    else
      return ''
    endif
  catch /.*/
    echo "Couldn't execute new search"
  endtry
endfunction

function! s:CalculateSearchRegisterAndHighlightAll()
  try
    let @/ = s:GetCalculatedPattern()
    call s:ReHighlightAll()
  catch /.*/
    echo "Couldn't execute new search"
  endtry
endfunction

function! s:RecordInSearchHistory()
  try
    call add(g:current_star_search_history, deepcopy(g:current_star_searches))
  catch /.*/
    echo "Couldn't execute push to history"
  endtry
endfunction

function! s:DoPushPreparedSearch(search)
  try
    let l:current_star_searches_for_insertion = deepcopy(g:current_star_searches)
    call add(l:current_star_searches_for_insertion, a:search)
    call uniq(l:current_star_searches_for_insertion)
    let g:current_star_searches = l:current_star_searches_for_insertion
    call add(g:current_star_search_history, deepcopy(g:current_star_searches))
    call s:RecordInSearchHistory()
    call s:CalculateSearchRegisterAndHighlightAll()
  catch /.*/
    echo "Couldn't execute push search"
  endtry
endfunction

function! s:DoPushBoundedSearch(is_visual)
  let search = s:GetNextSearchTerm(a:is_visual)
  let prepared = s:SearchTermEscape(l:search)
  let bounded = '\<' . l:prepared . '\>'
  call s:DoPushPreparedSearch(l:bounded)
endfunction

function! s:DoPushUnboundedSearch(is_visual)
  let search = s:GetNextSearchTerm(a:is_visual)
  let prepared = s:SearchTermEscape(l:search)
  call s:DoPushPreparedSearch(l:prepared)
endfunction

function! s:DoRewindCurrentSearchHistory()
  try
    if s:GetCalculatedPattern() != @/
      let g:last_known_manual_search = @/
      call s:CalculateSearchRegisterAndHighlightAll()
    elseif len(g:current_star_search_history) > 1
      call remove(g:current_star_search_history, -1)
      let g:current_star_searches = deepcopy(g:current_star_search_history[-1])
      call s:CalculateSearchRegisterAndHighlightAll()
    else
      let @/ = g:last_known_manual_search
      call s:ReHighlightAll()
    endif
  catch /.*/
    echo "Couldn't execute rewind"
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

function! s:DoHighlight()
  let w:current_star_matches = []
  let idx = 0
  for searchTerm in g:current_star_searches
    if idx < len(g:search_highlight_colors)
      let highlightName = "StarPoundSearchIdx" . l:idx
      execute "highlight " . l:highlightName . " " . g:search_highlight_colors[l:idx]
      call add(w:current_star_matches, matchadd(l:highlightName, l:searchTerm, 70 + l:idx))
    endif
    let idx = l:idx + 1
  endfor
endfunction

function! s:ReHighlightAll()
  let currentWindow = winnr()
  windo call s:ReHighlight()
  execute currentWindow . 'wincmd w'
endfunction

function! s:ReHighlight()
  call s:KillHighlight()
  call s:DoHighlight()
  call SearchUtilsHighlightCurrent()
endfunction

function! SearchUtilsHighlightCurrent()
  let [bufnum, row, column, ignore] = getpos('.')
  if(exists("g:current_match_highlight"))
    exe "highlight SearchCurrentResult " . g:current_match_highlight
  else
    highlight SearchCurrentResult ctermbg=white ctermfg=black guibg=white guifg=black
  endif
  if exists('g:current_match_metadata')
    try
      call matchdelete(g:current_match_metadata)
    catch /.*/
    endtry
  end
  let matchlen = strlen(matchstr(strpart(getline('.'),column-1),@/))
  let target_pat = '\c\%#\%('.@/.'\)'
  let g:current_match_metadata = matchadd('SearchCurrentResult', target_pat, 101)
endfunction

command! VisualPushBoundedSearch :call s:DoPushBoundedSearch(1)
command! VisualPushUnboundedSearch :call s:DoPushUnboundedSearch(1)

command! PushBoundedSearch :call s:DoPushBoundedSearch(0)
command! PushUnboundedSearch :call s:DoPushUnboundedSearch(0)

command! RewindCurrentSearchHistory :call s:DoRewindCurrentSearchHistory()

vnoremap <silent> <Plug>(VisualPushBoundedSearch) :<C-U>VisualPushBoundedSearch<CR>:set hlsearch<CR>
vnoremap <silent> <Plug>(VisualPushUnboundedSearch) :<C-U>VisualPushUnboundedSearch<CR>:set hlsearch<CR>

nnoremap <silent> <Plug>(PushBoundedSearch) :<C-U>PushBoundedSearch<CR>:set hlsearch<CR>
nnoremap <silent> <Plug>(PushUnboundedSearch) :<C-U>PushUnboundedSearch<CR>:set hlsearch<CR>

nnoremap <silent> <Plug>(RewindCurrentSearchHistory) :<C-U>RewindCurrentSearchHistory<CR>:set hlsearch<CR>

augroup ReHighlightAutomation
  autocmd VimLeavePre * let @/ = g:last_known_manual_search
  autocmd WinEnter * call s:ReHighlightAll()
  autocmd WinNew * call s:ReHighlightAll()
  autocmd BufWinEnter * call s:DoHighlight()
  autocmd BufWinLeave * call s:KillHighlight()
augroup end

nnoremap <silent> <Plug>(highlight-and-focus-next) n:call SearchUtilsHighlightCurrent()<CR>
nnoremap <silent> <Plug>(highlight-and-focus-prev) N:call SearchUtilsHighlightCurrent()<CR>

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

" Nice to Haves:
"  - different highlight for each search term
"  - ability to search for a `TokenName` and match `tokenName`, `token_name`,
"    and other variants that make sense
