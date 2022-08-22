if exists('g:include_get_visual_selection')
  finish
endif

let g:include_get_visual_selection = 1

"{{{ Get Contents of `v` or `V` or (possibly) `<C-V>`

function! GetVisualSelectionAsString()
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

"}}}


"{{{ Useful to get `v` selection

" get line range
function! GetVisualLineRange()
  return [getpos("'<")[1], getpos("'>")[1]]
endfunction

"}}}
