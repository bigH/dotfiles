if exists('g:print_position')
  finish
endif

let g:print_position = 1

function FilePathAndPosition()
  return expand('%') . ':' . getcurpos()[1]
endfunction


