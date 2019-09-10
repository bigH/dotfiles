if exists('g:change_and_highlight')
  finish
endif
let g:change_and_highlight = 1

" TODO
if !1
  " plug mappings
  nnoremap <silent> <Plug>ChangeAndHighlightNormal  :<C-U>call <SID>do_change_and_highlight('setup')<CR>
  vnoremap <silent> <Plug>ChangeAndHighlightVisual  :<C-U>call <SID>do_change_and_highlight(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>

  if !exists("g:change_and_highlight_no_mappings") || ! g:change_and_highlight_no_mappings
    nmap <silent> gc <Plug>ChangeAndHighlightNormal
    vmap <silent> gc <Plug>ChangeAndHighlightInsert
  endif
endif
