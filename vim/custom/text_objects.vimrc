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

" line = 'l'
call textobj#user#plugin('line', {
\   '-': {
\     'select-a-function': 'CurrentLineA',
\     'select-a': 'al',
\     'select-i-function': 'CurrentLineI',
\     'select-i': 'il',
\   },
\ })

function! CurrentLineA()
  normal! 0
  let head_pos = getpos('.')
  normal! $
  let tail_pos = getpos('.')
  return ['v', head_pos, tail_pos]
endfunction

function! CurrentLineI()
  normal! ^
  let head_pos = getpos('.')
  normal! g_
  let tail_pos = getpos('.')
  let non_blank_char_exists_p = getline('.')[head_pos[2] - 1] !~# '\s'
  return
  \ non_blank_char_exists_p
  \ ? ['v', head_pos, tail_pos]
  \ : 0
endfunction

" last pattern = '/' & '?'
call textobj#user#plugin('lastpat', {
\      'n': {
\        'select': ['a/', 'i/'],
\        '*select-function*': 's:select_n',
\        '*sfile*': expand('<sfile>')
\      },
\      'N': {
\        'select': ['a?', 'i?'],
\        '*select-function*': 's:select_N',
\        '*sfile*': expand('<sfile>')
\      },
\    })

function! s:select_n()
  return s:select(0)
endfunction

function! s:select_N()
  return s:select(1)
endfunction

function! s:select(opposite_p)
  let forward_p = (v:searchforward && !a:opposite_p)
  \               || (!v:searchforward && a:opposite_p)

  if search(@/, 'ce' . (forward_p ? '' : 'b')) == 0
    return 0
  endif
  let end_position = getpos('.')

  if search(@/, 'bc') == 0
    return 0
  endif
  let start_position = getpos('.')

  return ['v', start_position, end_position]
endfunction

