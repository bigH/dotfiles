if exists('g:custom_text_objects')
  finish
endif
let g:custom_text_objects = 1

" ruby constant = 'R'
call textobj#user#plugin('constant', {
      \   'constant': {
      \     'pattern': '\C\<\([_A-Z]\+[a-z]*\)\+\(::\([_A-Z]\+[a-z]*\)\+\)*\>',
      \     'select': ['ar', 'ir'],
      \   },
      \ })

"{{{ Tree Text Object

" `a tree` or `in tree`
" `outer tree` or `in outer tree`
call textobj#user#plugin('indenttree', {
      \   'inner': {
      \     'select-a-function': 'SelectTree',
      \     'select-a': 'aT',
      \     'select-i-function': 'SelectTreeChildren',
      \     'select-i': 'iT',
      \   },
      \   'outer': {
      \     'select-a-function': 'SelectTreeParent',
      \     'select-a': 'oT',
      \     'select-i-function': 'SelectTreeSiblings',
      \     'select-i': 'ioT',
      \   },
      \ })

function! SelectTree()
  let start_pos = getpos('.')
  let indent = indent('.')
  let end_pos = getpos('.')
  normal! j
  while indent('.') > l:indent && len(trim(line('.'))) != 0
    let end_pos = getpos('.')
    normal! j
  endwhile
  return ['V', l:start_pos, l:end_pos]
endfunction

function! SelectTreeSiblings()
  let start_pos = getpos('.')
  let indent = indent('.')
  normal! k
  while indent('.') >= l:indent && len(trim(line('.'))) != 0
    let start_pos = getpos('.')
    normal! k
  endwhile
  normal! j
  let end_pos = getpos('.')
  normal! j
  while indent('.') >= l:indent && len(trim(line('.'))) != 0
    let end_pos = getpos('.')
    normal! j
  endwhile
  return ['V', l:start_pos, l:end_pos]
endfunction

function! SelectTreeChildren()
  let indent = indent('.')
  normal! j
  let start_pos = getpos('.')
  if indent('.') > l:indent && len(trim(line('.'))) != 0
    while indent('.') > l:indent && len(trim(line('.'))) != 0
      let end_pos = getpos('.')
      normal! j
    endwhile
    return ['V', l:start_pos, l:end_pos]
  else
    return 0
  endif
endfunction

function! SelectTreeParent()
  let indent = indent('.')
  normal! k
  while indent('.') >= l:indent && len(trim(line('.'))) != 0
    normal! k
  endwhile
  return SelectTree()
endfunction

"}}}
