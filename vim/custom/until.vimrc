if exists('g:custom_until')
  finish
endif
let g:custom_until = 1
" TODO:
" - `cU=` is awkward because `U` is awkward
" - `cU=` could be used to mean until the last `=`
" - in situations where the character is not present it just uses the
"   character under the cursor - which is bad

function! s:until_text_object(forward)
  let char = nr2char(getchar())
  let line = getline('.')
  let [bufnum, row, column, ignore] = getpos('.')
  if a:forward
    let chars = split(strpart(l:line, l:column), '\zs')
    let num = index(l:chars, l:char)
    if l:num > 0 && l:chars[l:num - 1] != ' '
      execute 'silent! normal! v' . l:num . 'l'
    elseif l:num > 1
      execute 'silent! normal! v' . (l:num - 1) . 'l'
    else
    endif
  else
    let chars = reverse(split(strpart(l:line, 0, l:column - 1), '\zs'))
    let num = index(l:chars, l:char)
    if l:num > 0 && l:chars[l:num - 1] != ' '
      execute 'silent! normal! v' . l:num . 'h'
    elseif l:num > 1
      execute 'silent! normal! v' . (l:num - 1) . 'h'
    else
    endif
  endif
endfunction

onoremap <silent> <Plug>until_forward v:call <SID>until_text_object(1)<CR>
onoremap <silent> <Plug>until_backward v:call <SID>until_text_object(0)<CR>

vnoremap <silent> <Plug>until_forward_visual v:call <SID>until_text_object(1)<CR>
vnoremap <silent> <Plug>until_backward_visual v:call <SID>until_text_object(0)<CR>

if !exists('g:until_no_mappings') || g:until_no_mappings == 0
  omap <silent> u <Plug>until_forward
  omap <silent> U <Plug>until_backward

  vmap <silent> u <Plug>until_forward_visual
  vmap <silent> U <Plug>until_backward_visual
endif
