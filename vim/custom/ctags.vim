let g:tagbar_type_javascript = {
  \ 'ctagstype': 'javascript',
  \ 'kinds': [
    \ 'A:arrays',
    \ 'P:properties',
    \ 'T:tags',
    \ 'O:objects',
    \ 'G:generator functions',
    \ 'F:functions',
    \ 'C:constructors/classes',
    \ 'M:methods',
    \ 'V:variables',
    \ 'I:imports',
    \ 'E:exports',
    \ 'S:styled components'
  \ ]
\ }

let g:tagbar_type_typescript = {
  \ 'ctagstype': 'typescript',
  \ 'kinds': [
    \ 'c:classes',
    \ 'n:modules',
    \ 'f:functions',
    \ 'v:variables',
    \ 'v:varlambdas',
    \ 'm:members',
    \ 'i:interfaces',
    \ 'e:enums',
  \ ]
\ }

let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : ($DOT_FILES_DIR . '/' . 'utils/markdown-ctags.py'),
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

