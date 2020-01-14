if exists('g:custom_visual_star')
  " finish
endif
let g:custom_visual_star = 1

let g:current_star_searches = []

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

function! EscapeForSearchTerms(searchTerm)
  return escape(a:searchTerm, '\\/.*$^~[]')
endfunction

function! QuoteForSearchTerms(searchTerm)
  return '\<' . a:searchTerm . '\>'
endfunction

function! MapFriendlyEscapeAndQuote(idx, searchTerm)
  return QuoteForSearchTerms(EscapeForSearchTerms(a:searchTerm))
endfunction

function! s:ExecuteSearch()
  try
    let l:new_list = deepcopy(g:current_star_searches)
    let l:escaped = map(l:new_list, function('MapFriendlyEscapeAndQuote'))
    let l:special_pattern = '\V\(' . join(l:escaped, '\|') . '\)'
    let @/ = l:special_pattern
  catch /.*/
    echo "Couldn't execute new search"
  endtry
endfunction

function! s:DoAppendSearch(is_visual)
  try
    let search = s:GetNextSearchTerm(a:is_visual)
    call add(g:current_star_searches, l:search)
    call s:ExecuteSearch()
  catch /.*/
    echo "Couldn't execute append search"
  endtry
endfunction

function! s:DoNewSearch(is_visual)
  try
    let search = s:GetNextSearchTerm(a:is_visual)
    let g:current_star_searches = [l:search]
    call s:ExecuteSearch()
  catch /.*/
    echo "Couldn't execute new search"
  endtry
endfunction

command! -range VisualAppendSearch :call s:DoAppendSearch(1)
command! -range VisualNewSearch :call s:DoNewSearch(1)

command! -range AppendSearch :call s:DoAppendSearch(0)
command! -range NewSearch :call s:DoNewSearch(0)

vnoremap * :VisualAppendSearch<CR>
vnoremap # :VisualNewSearch<CR>

nnoremap * :AppendSearch<CR>
nnoremap # :NewSearch<CR>

" Nice to Haves:
"  - different highlight for each search term
"  - ability to search for a `TokenName` and match `tokenName`, `token_name`,
"    and other variants that make sense
