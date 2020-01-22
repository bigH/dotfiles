if exists('g:custom_visual_star')
  " finish
endif

let g:custom_visual_star = 1

let g:current_star_searches = []
let g:current_star_searches_word_boundaries = 1

let g:current_star_search_history = [[]]

" TODO use this
let g:last_known_manual_search = @/

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
    let search = expand("<cword>")
    if (a:is_visual == 1)
      let search = s:GetVisualSelectionAsString()
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

function! s:ExecuteSearch()
  try
    let @/ = s:GetCalculatedPattern()
  catch /.*/
    echo "Couldn't execute new search"
  endtry
endfunction

" makes sure to dedupe search terms and history - though history should be
" impossible given all elements
function! s:RecordInSearchHistory()
  try
    let l:current_star_searches = uniq(g:current_star_searches)
    let l:current_star_searches_copy = deepcopy(g:current_star_searches)
    call add(g:current_star_search_history, l:current_star_searches_copy)
  catch /.*/
    echo "Couldn't execute push to history"
  endtry
endfunction

function! s:DoPushBoundedSearch(is_visual)
  try
    let search = s:GetNextSearchTerm(a:is_visual)
    call add(g:current_star_searches, '\<' . s:SearchTermEscape(l:search) . '\>')
    call s:RecordInSearchHistory()
    call s:ExecuteSearch()
  catch /.*/
    echo "Couldn't execute push search"
  endtry
endfunction

function! s:DoPushUnboundedSearch(is_visual)
  try
    let search = s:GetNextSearchTerm(a:is_visual)
    call add(g:current_star_searches, s:SearchTermEscape(l:search))
    call s:RecordInSearchHistory()
    call s:ExecuteSearch()
  catch /.*/
    echo "Couldn't execute new search"
  endtry
endfunction

function! s:DoRewindCurrentSearchHistory()
  try
    if s:GetCalculatedPattern() == @/
      if len(g:current_star_search_history) > 1
        call remove(g:current_star_search_history, -1)
        let g:current_star_searches = deepcopy(g:current_star_search_history[-1])
        call s:ExecuteSearch()
      endif
    else
      call s:ExecuteSearch()
    endif
  catch /.*/
    echo "Couldn't execute rewind"
  endtry
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

if !exists('g:star_pound_no_mappings') || g:star_pound_no_mappings == 0
  if !exists('g:star_pound_no_visual_mappings') || g:star_pound_no_visual_mappings == 0
    vmap * <Plug>VisualPushBoundedSearch
    vmap # <Plug>VisualPushUnboundedSearch
  endif

  if !exists('g:star_pound_no_normal_mappings') || g:star_pound_no_normal_mappings == 0
    nmap * <Plug>PushBoundedSearch
    nmap # <Plug>PushUnboundedSearch
  endif

  if !exists('g:star_pound_no_rewind_mappings') || g:star_pound_no_rewind_mappings == 0
    nmap <BS> <Plug>RewindCurrentSearchHistory
  endif
endif

" Nice to Haves:
"  - different highlight for each search term
"  - ability to search for a `TokenName` and match `tokenName`, `token_name`,
"    and other variants that make sense
