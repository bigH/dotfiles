if exists('g:custom_blinkenmatchen')
  finish
endif

let g:custom_blinkenmatchen = 1

nnoremap <silent> <Plug>(blinkenmatchen-next) n:call HLBlink(0.1)<CR>
nnoremap <silent> <Plug>(blinkenmatchen-prev) N:call HLBlink(0.1)<CR>

if !exists('g:blinkenmatchen_no_mappings') || g:blinkenmatchen_no_mappings == 0
  " Search mappings: These will make it so that going to the next one in a
  " search will center on the line it's found in.
  nmap <silent> n <Plug>(blinkenmatchen-next)
  nmap <silent> N <Plug>(blinkenmatchen-prev)
endif

function! HLBlink(blinktime)
  let [bufnum, row, column, ignore] = getpos('.')
  if(exists("g:blinkenmatchen_highlight"))
    exe "highlight SearchCurrentResult " . g:blinkenmatchen_highlight
  else
    highlight SearchCurrentResult ctermbg=lightgreen ctermfg=black
  endif
  if exists('g:ring')
    call matchdelete(g:ring)
  end
  let matchlen = strlen(matchstr(strpart(getline('.'),column-1),@/))
  let target_pat = '\c\%#\%('.@/.'\)'
  let g:ring = matchadd('SearchCurrentResult', target_pat, 101)
endfunction
