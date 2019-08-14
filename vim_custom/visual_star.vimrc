if exists('g:visual_star')
  finish
endif
let g:visual_star = 1

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

" next
function! s:NextHl()
    try
        let search = s:GetVisualSelectionAsString()
        let @/ = escape(search, '\\/.*$^~[]')
        let pattern = "normal! /\\V" . search . "\<cr>"
        execute pattern
    catch /.*/
        echo "Couldn't Search for Visual Star"
    endtry
endfunction

" prev
function! s:PrevHl()
    try
        let search = s:GetVisualSelectionAsString()
        let @/ = escape(search, '\\/.*$^~[]')
        let pattern = "normal! ?\\V" . search . "\<cr>"
        execute pattern
    catch /.*/
        echo "Couldn't Search for Visual Star"
    endtry
endfunction

command! -range VstarN :call s:NextHl()
command! -range VstarP :call s:PrevHl()

vnoremap * :VstarN<CR>
vnoremap # :VstarP<CR>

" TODO it'd be nicec to be able to append alternative search terms to the
" search, like if `/\\VFoo` was the search term, selecting `Bar` and hitting
" `*` or `#` could make it `/\\V(Foo|Bar)` or whatever the equivalent
