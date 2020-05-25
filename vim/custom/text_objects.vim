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
