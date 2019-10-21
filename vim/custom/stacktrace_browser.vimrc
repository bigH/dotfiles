if exists('g:custom_stacktrace_browser')
  finish
endif
let g:custom_stacktrace_browser = 1

" get content of visual selection
function! s:GetVisualSelectionAsArray()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    return getline(line_start, line_end)
endfunction

" TODO complete this
