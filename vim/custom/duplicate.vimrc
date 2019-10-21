if exists('g:custom_duplicate')
  finish
endif
let g:custom_duplicate = 1

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

function! s:do_duplicate(type, ...)
  let g:do_duplicate_buffer = s:motion_get(a:type, a:0)
  let contents = g:do_duplicate_buffer.text

  let motion_type = g:do_duplicate_buffer.type

  let is_visual = 0
  if motion_type =~ '^([Vv]|\<C-V>)$'
    let is_visual = 1
  endif

  let old_reg_value = s:save_reg('d')

  let old_line = line('.')
  let old_col = col('.')

  silent! call setreg('d', contents)
  if is_visual == 0
    silent call cursor(g:do_duplicate_buffer.end.line, g:do_duplicate_buffer.end.column)
    silent execute 'normal! "dp'
    silent call cursor(g:do_duplicate_buffer.end.line, g:do_duplicate_buffer.end.column)
  else
    silent execute 'normal! `>"dpgv'
  endif

  call s:restore_reg('d', old_reg_value)
endfunction

nnoremap <silent> <Plug>DuplicateNormal :<C-U>set operatorfunc=<SID>do_duplicate<CR>g@
vnoremap <silent> <Plug>DuplicateVisual :<C-U>call <SID>do_duplicate(visualmode(), 1)<CR>

if !exists("g:duplicate_no_mappings") || ! g:duplicate_no_mappings
  " TODO This mapping conflicts with `commentary`, and i need to figure that
  " mapping out
  nmap <silent> gd <Plug>DuplicateNormal
  vmap <silent> gd <Plug>DuplicateVisual
endif

