if exists('g:duplicate')
  finish
endif
let g:duplicate = 1

let g:duplicate_register_name = 'd'

" TODO
"  - undo fragments actions

function! s:apply_type(pos, type)
  let pos = a:pos
  if a:type ==# 'V'
    let pos.column = col([pos.line, '$'])
  endif
  return pos
endfunction

function! s:store_pos(start, end)
  return [s:getpos(a:start), s:getpos(a:end)]
endfunction

function! s:getpos(mark)
  let pos = getpos(a:mark)
  let result = {}
  return {
        \ 'buffer': pos[0],
        \ 'line': pos[1],
        \ 'column': pos[2],
        \ 'offset': pos[3]
        \ }
endfunction

function! s:save_reg(name)
  try
    return [getreg(a:name), getregtype(a:name)]
  catch /.*/
    return ['', '']
  endtry
endfunction

function! s:restore_reg(name, reg)
  silent! call setreg(a:name, a:reg[0], a:reg[1])
endfunction

" get content of visual selection as string
function! s:motion_get(type, vis)
  let reg = s:save_reg('"')
  let reg_star = s:save_reg('*')
  let reg_plus = s:save_reg('+')
  if a:vis
    let type = a:type
    let [start, end] = s:store_pos("'<", "'>")
    silent normal! gvy
    if &selection ==# 'exclusive' && start != end
      let end.column -= len(matchstr(@@, '\_.$'))
    endif
  else
    let selection = &selection
    let &selection = 'inclusive'
    if a:type == 'line'
      let type = 'V'
      let [start, end] = s:store_pos("'[", "']")
      silent execute "normal! '[V']y"
    elseif a:type == 'block'
      let type = "\<C-V>"
      let [start, end] = s:store_pos("'[", "']")
      silent execute "normal! `[\<C-V>`]y"
    else
      let type = 'v'
      let [start, end] = s:store_pos("'[", "']")
      silent execute "normal! `[v`]y"
    endif
    let &selection = selection
  endif
  let text = getreg('@')
  call s:restore_reg('"', reg)
  call s:restore_reg('*', reg_star)
  call s:restore_reg('+', reg_plus)
  return {
        \ 'text': text,
        \ 'type': type,
        \ 'start': start,
        \ 'end': s:apply_type(end, type)
        \ }
endfunction

" TODO properly handle visual mode and putting the cursor in the right place
" regardless of the motion being done
function! s:do_duplicate(type, ...)
  let g:do_duplicate_buffer = s:motion_get(a:type, a:0)
  let l:motion_type = g:do_duplicate_buffer.type
  let l:contents = g:do_duplicate_buffer.text
  setreg(g:duplicate_register_name, contents)
  " TODO need to go to the beginning of the motion
  silent execute 'normal! <Esc>"' . g:duplicate_register_name . 'P'
  if motion_type =~ '^([Vv]|\<C-V>)$'
    silent normal! gv
    silent! call visualrepeat#set("\<Plug>DuplicateRepeatNormal")
  endif
  silent call repeat#set("\<Plug>DuplicateRepeat")
  startinsert
endfunction

function! s:do_duplicate_repeat(is_visual)
  silent execute 'normal! "' . g:duplicate_register_name . 'P'
  " TODO if selection is the same as visual
  let l:motion_type = g:do_duplicate_buffer.type
  silent call repeat#set("\<Plug>DuplicateRepeat")
  if is_visual == 1
    silent! call visualrepeat#set("\<Plug>DuplicateRepeatNormal")
  end
  silent! call repeat#set("\<Plug>DuplicateRepeatVisual")
endfunction

nnoremap <silent> <Plug>DuplicateRepeatVisual :call <SID>do_duplicate_repeat(1)<CR>
nnoremap <silent> <Plug>DuplicateRepeatNormal :call <SID>do_duplicate_repeat(0)<CR>
nnoremap <silent> <Plug>DuplicateNormal :<C-U>set operatorfunc=<SID>do_duplicate<CR>g@
vnoremap <silent> <Plug>DuplicateVisual :<C-U>call <SID>do_duplicate(visualmode(), 1)<CR>

if !exists("g:duplicate_no_mappings") || ! g:duplicate_no_mappings
  " TODO This mapping conflicts with `commentary`, and i need to figure that
  " mapping out
  nmap <silent> gd <Plug>DuplicateNormal
  vmap <silent> gd <Plug>DuplicateVisual
endif

