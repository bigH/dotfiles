if exists('g:custom_change_repeat')
  finish
endif
let g:custom_change_repeat = 1

" TODO
"  - undo fragments the first action
"  - doesn't take number args for motions

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

function! s:do_change_repeat(type, ...)
  let g:do_change_repeat_buffer = s:motion_get(a:type, a:0)
  let l:contents = g:do_change_repeat_buffer.text
  let @/ = ('\C' . escape(contents, '\\/.*$^~[]'))
  silent normal! gnd
  silent call repeat#set("\<Plug>(ChangeRepeatRepeat)")
  startinsert
endfunction

function! s:do_change_repeat_repeat()
  silent normal! gn".p
  silent call repeat#set("\<Plug>(ChangeRepeatRepeat)")
endfunction

nnoremap <silent> <Plug>(ChangeRepeatRepeat) :call <SID>do_change_repeat_repeat()<CR>
nnoremap <silent> <Plug>(ChangeRepeatNormal) :<C-U>set operatorfunc=<SID>do_change_repeat<CR>g@
vnoremap <silent> <Plug>(ChangeRepeatVisual) :<C-U>call <SID>do_change_repeat(visualmode(), 1)<CR>

if !exists("g:change_repeat_no_mappings") || ! g:change_repeat_no_mappings
  nmap <silent> gc <Plug>(ChangeRepeatNormal)
  vmap <silent> gc <Plug>(ChangeRepeatVisual)
  " TODO this doesn't work at all
  " nmap <silent> gcc 0gc_
endif
