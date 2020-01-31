if exists('g:custom_search_utils')
  finish
endif

let g:custom_search_utils = 1

let g:current_star_searches = []
let g:current_star_search_history = [[]]
let g:last_known_manual_search = @/

let g:search_highlight_colors = [
      \   'ctermbg=cyan ctermfg=black',
      \   'ctermbg=magenta ctermfg=black',
      \   'ctermbg=yellow ctermfg=black',
      \   'ctermbg=red ctermfg=black',
      \   'ctermbg=blue ctermfg=black',
      \   'ctermbg=green ctermfg=black',
      \   'ctermbg=darkgrey ctermfg=black',
      \   'ctermbg=brown ctermfg=black',
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
  " try
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
  " catch /.*/
  "   echo "Couldn't get next search term"
  " endtry
endfunction

function! s:SearchTermEscape(search)
  return escape(a:search, '\\/.*$^~[]')
endfunction

function! s:GetCalculatedPattern()
  " try
    if len(g:current_star_searches) > 0
      let l:searches = deepcopy(g:current_star_searches)
      return '\V\(' . join(l:searches, '\|') . '\)'
    else
      return ''
    endif
  " catch /.*/
  "   echo "Couldn't execute new search"
  " endtry
endfunction

function! s:ExecuteSearch()
  " try
    let @/ = s:GetCalculatedPattern()
  " catch /.*/
  "   echo "Couldn't execute new search"
  " endtry
endfunction

" makes sure to dedupe search terms and history - though history should be
" impossible given all elements
function! s:RecordInSearchHistory()
  " try
    let l:current_star_searches = uniq(g:current_star_searches)
    let l:current_star_searches_copy = deepcopy(g:current_star_searches)
    call add(g:current_star_search_history, l:current_star_searches_copy)
  " catch /.*/
  "   echo "Couldn't execute push to history"
  " endtry
endfunction

function! s:DoPushBoundedSearch(is_visual)
  " try
    let search = s:GetNextSearchTerm(a:is_visual)
    call add(g:current_star_searches, '\<' . s:SearchTermEscape(l:search) . '\>')
    call s:ReHighlightAll()
    call s:RecordInSearchHistory()
    call s:ExecuteSearch()
  " catch /.*/
  "   echo "Couldn't execute push search"
  " endtry
endfunction

function! s:DoPushUnboundedSearch(is_visual)
  " try
    let search = s:GetNextSearchTerm(a:is_visual)
    call add(g:current_star_searches, s:SearchTermEscape(l:search))
    call s:ReHighlightAll()
    call s:RecordInSearchHistory()
    call s:ExecuteSearch()
  " catch /.*/
  "   echo "Couldn't execute new search"
  " endtry
endfunction

function! s:DoRewindCurrentSearchHistory()
  " try
    if s:GetCalculatedPattern() == @/
      if len(g:current_star_search_history) > 1
        call remove(g:current_star_search_history, -1)
        let g:current_star_searches = deepcopy(g:current_star_search_history[-1])
        call s:ReHighlightAll()
        call s:ExecuteSearch()
      elseif @/ == g:last_known_manual_search
        let @/ = ''
      else
        let @/ = g:last_known_manual_search
      endif
    elseif @/ == g:last_known_manual_search
      let @/ = ''
    else
      let @/ = g:last_known_manual_search
    endif
  " catch /.*/
  "   echo "Couldn't execute rewind"
  " endtry
endfunction

function! s:PushHighlight()
  " try
    if len(w:current_star_matches) < len(g:search_highlight_colors)
      let search = g:current_star_searches[-1]
      let idx = len(w:current_star_matches)
      let highlightName = "StarPoundSearchIdx" . l:idx
      execute "highlight " . l:highlightName . " " . g:search_highlight_colors[l:idx]
      call add(w:current_star_matches, matchadd(l:highlightName, l:search, 100))
    endif
  " catch /.*/
  "   echo "Couldn't push highlight"
  " endtry
endfunction

function! s:PopHighlight()
  " try
    if len(w:current_star_matches) - 1 == len(g:current_star_searches)
      call matchdelete(w:current_star_matches[-1])
      call remove(w:current_star_matches, -1)
    endif
  " catch /.*/
  "   echo "Couldn't pop highlight"
  " endtry
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
    let highlightName = "StarPoundSearchIdx" . l:idx
    execute "highlight " . l:highlightName . " " . g:search_highlight_colors[l:idx]
    call add(w:current_star_matches, matchadd(l:highlightName, l:searchTerm, 100))
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
    highlight SearchCurrentResult ctermbg=white ctermfg=black
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

command! -range VisualPushBoundedSearch :call s:DoPushBoundedSearch(1)
command! -range VisualPushUnboundedSearch :call s:DoPushUnboundedSearch(1)

command! -range PushBoundedSearch :call s:DoPushBoundedSearch(0)
command! -range PushUnboundedSearch :call s:DoPushUnboundedSearch(0)

command! -range RewindCurrentSearchHistory :call s:DoRewindCurrentSearchHistory()

vnoremap <silent> <Plug>VisualPushBoundedSearch :<C-U>VisualPushBoundedSearch<CR>:set hlsearch<CR>
vnoremap <silent> <Plug>VisualPushUnboundedSearch :<C-U>VisualPushUnboundedSearch<CR>:set hlsearch<CR>

nnoremap <silent> <Plug>PushBoundedSearch :<C-U>PushBoundedSearch<CR>:set hlsearch<CR>
nnoremap <silent> <Plug>PushUnboundedSearch :<C-U>PushUnboundedSearch<CR>:set hlsearch<CR>

nnoremap <silent> <Plug>RewindCurrentSearchHistory :<C-U>RewindCurrentSearchHistory<CR>:set hlsearch<CR>

augroup ReHighlightAutomation
  autocmd VimEnter * call s:ReHighlightAll()
  autocmd WinEnter * call s:ReHighlight()
  autocmd WinNew * call s:ReHighlight()
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
    vmap * <Plug>VisualPushBoundedSearch
    vmap # <Plug>VisualPushUnboundedSearch
  endif

  if !exists('g:search_utils_no_normal_mappings') || g:search_utils_no_normal_mappings == 0
    nmap * <Plug>PushBoundedSearch
    nmap # <Plug>PushUnboundedSearch
  endif

  if !exists('g:search_utils_no_rewind_mappings') || g:search_utils_no_rewind_mappings == 0
    nmap <BS> <Plug>RewindCurrentSearchHistory
  endif
endif

" Nice to Haves:
"  - different highlight for each search term
"  - ability to search for a `TokenName` and match `tokenName`, `token_name`,
"    and other variants that make sense
