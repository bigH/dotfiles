if exists('g:custom_tree_text_object')
  finish
endif
let g:custom_tree_text_object = 1

call textobj#user#plugin('journal', {
      \   'tree': {
      \     'select-a-function': 'TreeSibs',
      \     'select-a': 'at',
      \     'select-i-function': 'TreeThis',
      \     'select-i': 'it',
      \   },
      \ })

function! TreeThis()
  normal! 0
  let start_pos = getpos('.')
  let indent = indent('.')
  let end_pos = getpos('.')
  normal! j
  while indent('.') > l:indent
    let end_pos = getpos('.')
    normal! j
  endwhile
  return ['V', l:start_pos, l:end_pos]
endfunction

function! TreeSibs()
  normal! 0
  let start_pos = getpos('.')
  let indent = indent('.')
  normal! k
  while indent('.') >= l:indent
    let start_pos = getpos('.')
    normal! k
  endwhile
  normal! j
  let end_pos = getpos('.')
  normal! j
  while indent('.') >= l:indent
    let end_pos = getpos('.')
    normal! j
  endwhile
  return ['V', l:start_pos, l:end_pos]
endfunction
