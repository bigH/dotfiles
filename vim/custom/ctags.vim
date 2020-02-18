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

let g:tagbar_type_go = {
  \ 'ctagstype': 'go',
  \ 'kinds' : [
    \'p:package',
    \'f:function',
    \'v:variables',
    \'t:type',
    \'c:const'
  \]
\}

if executable('ripper-tags')
  let g:tagbar_type_ruby = {
    \ 'kinds'      : ['m:modules',
                    \ 'c:classes',
                    \ 'C:constants',
                    \ 'F:singleton methods',
                    \ 'f:methods',
                    \ 'a:aliases'],
    \ 'kind2scope' : { 'c' : 'class',
                      \ 'm' : 'class' },
    \ 'scope2kind' : { 'class' : 'c' },
    \ 'ctagsbin'   : 'ripper-tags',
    \ 'ctagsargs'  : ['-f', '-']
  \ }
else
  let g:tagbar_type_ruby = {
    \ 'kinds' : [
      \ 'm:modules',
      \ 'c:classes',
      \ 'd:describes',
      \ 'C:contexts',
      \ 'f:methods',
      \ 'F:singleton methods'
    \ ]
  \ }
endif

" if using rust.vim
let g:rust_use_custom_ctags_defs = 1

let g:tagbar_type_rust = {
  \ 'ctagsbin' : 'ctags',
  \ 'ctagstype' : 'rust',
  \ 'kinds' : [
    \ 'n:modules',
    \ 's:structures:1',
    \ 'i:interfaces',
    \ 'c:implementations',
    \ 'f:functions:1',
    \ 'g:enumerations:1',
    \ 't:type aliases:1:0',
    \ 'v:constants:1:0',
    \ 'M:macros:1',
    \ 'm:fields:1:0',
    \ 'e:enum variants:1:0',
    \ 'P:methods:1',
  \ ],
  \ 'sro': '::',
  \ 'kind2scope' : {
    \ 'n': 'module',
    \ 's': 'struct',
    \ 'i': 'interface',
    \ 'c': 'implementation',
    \ 'f': 'function',
    \ 'g': 'enum',
    \ 't': 'typedef',
    \ 'v': 'variable',
    \ 'M': 'macro',
    \ 'm': 'field',
    \ 'e': 'enumerator',
    \ 'P': 'method',
  \ },
\ }

let g:tagbar_type_scala = {
  \ 'ctagstype' : 'scala',
  \ 'sro'       : '.',
  \ 'kinds'     : [
    \ 'p:packages',
    \ 'T:types:1',
    \ 't:traits',
    \ 'o:objects',
    \ 'O:case objects',
    \ 'c:classes',
    \ 'C:case classes',
    \ 'm:methods',
    \ 'V:values:1',
    \ 'v:variables:1'
  \ ]
\ }

