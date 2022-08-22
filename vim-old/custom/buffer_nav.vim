if exists('g:custom_buffer_nav')
  finish
endif

let g:custom_buffer_nav = 1

let g:skip_buffer_name_regexes = ['^NERD_tree']
let g:skip_buffer_wininfo_props = ['loclist', 'quickfix', 'terminal']

function s:ShouldSkipBuffer()
  let name = buffer_name()
  for regex in g:skip_buffer_name_regexes
    if l:name =~ l:regex
      return 1
    endif
  endfor
  let wininfo = getwininfo()[winnr() - 1]
  for prop_name in g:skip_buffer_wininfo_props
    if get(l:wininfo, l:prop_name)
      return 1
    endif
  endfor
  return 0
endfunction

function s:GoToBufferAdjacent(action_name)
  let starting_buffer = bufnr()
  let action_command = 'b' . a:action_name . '!'
  execute l:action_command
  while (s:ShouldSkipBuffer())
    execute l:action_command
  endwhile
endfunction

function s:GoToBufferPrevious()
  call s:GoToBufferAdjacent('previous')
endfunction

function s:GoToBufferNext()
  call s:GoToBufferAdjacent('next')
endfunction

function s:GoToBufferFirst()
  bfirst
  if s:ShouldSkipBuffer()
    call s:GoToBufferNext()
  endif
endfunction

function s:GoToBufferLast()
  blast
  if s:ShouldSkipBuffer()
    call s:GoToBufferPrevious()
  endif
endfunction

nnoremap <silent> <Plug>(first_buffer)    :<C-U>call <SID>GoToBufferFirst()<CR>
nnoremap <silent> <Plug>(previous_buffer) :<C-U>call <SID>GoToBufferPrevious()<CR>
nnoremap <silent> <Plug>(next_buffer)     :<C-U>call <SID>GoToBufferNext()<CR>
nnoremap <silent> <Plug>(last_buffer)     :<C-U>call <SID>GoToBufferLast()<CR>

if !exists('g:buffer_nav_no_mappings') || g:buffer_nav_no_mappings == 0
  nmap <silent> <C-H> <Plug>(first_buffer)
  nmap <silent> H     <Plug>(previous_buffer)
  nmap <silent> L     <Plug>(next_buffer)
  nmap <silent> <C-L> <Plug>(last_buffer)
endif
