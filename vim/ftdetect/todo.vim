let g:todo_indent = 4
let g:todo_note_indent = g:todo_indent + 2

function! s:PerformAppropriateCR()
  let line=getline('.')
  if l:line =~ '^\s\+- \[ \]\s*$'
    return "\<Esc>\<S-Tab>A"
  elseif l:line =~ '^- \[ \]\s*$'
    return "\<Esc>0C## "
  elseif l:line =~ '^\s*- \[.\].\+$'
    return "\<CR>-\<Space>[\<Space>]\<Space>"
  elseif l:line =~ '^##\s*$'
    return "\<Esc>0C# "
  elseif l:line =~ '^#\s*$'
    return "\<Esc>O\<Esc>0DjA"
  elseif l:line =~ '^#.*$'
    return "\<CR>-\<Space>[\<Space>]\<Space>"
  else
    return "\<CR>"
  endif
endfunction

function! s:PerformAppropriateDent(indent)
  let [bufnum, row, column, ignore] = getpos('.')
  let previous = row - 1
  let current_line = getline('.')
  let previous_line = getline(l:previous)
  let indent_amount = 0
  if a:indent == 1
    if l:previous >= 1 &&
       \ l:current_line =~ '^\s*- \[ \]\s*$' &&
       \ l:previous_line =~ '^\s*- \[.\]\s.*$' &&
       \ indent('.') >= indent(l:previous) + g:todo_indent
      let indent_amount = indent(l:previous) + g:todo_note_indent
      call setline('.', repeat(' ', l:indent_amount))
      call setpos('.', [bufnum, row, l:indent_amount, ignore])
    else
      normal >>
      call setpos('.', [bufnum, row, column + g:todo_indent, ignore])
    endif
  else
    if l:current_line =~ '^\s*$' && l:previous >= 1
      let new_line = repeat(' ', indent(l:previous) + g:todo_indent) . '- [ ] '
      call setline('.', l:new_line)
      call setpos('.', [bufnum, row, len(l:new_line), ignore])
    else
      let original_indent_amount = indent('.')
      normal <<
      if (l:original_indent_amount == 0)
        call setpos('.', [bufnum, row, column, ignore])
      else
        call setpos('.', [bufnum, row, column - g:todo_indent, ignore])
      endif
    endif
  endif
endfunction

function! s:SaveReg(name)
  try
    return [getreg(a:name), getregtype(a:name)]
  catch /.*/
    return ['', '']
  endtry
endfunction

function! s:RestoreReg(name, reg)
  silent! call setreg(a:name, a:reg[0], a:reg[1])
endfunction

function! s:SetTodoState(char)
  execute 's/\v^(\s*)- \[.\] (.*)$/\1- \[' . a:char . '\] \2'
endfunction

function! s:GetCurrentStateChar()
  let line=getline('.')
  if l:line =~ '\s*- \[.\].*'
    return split(split(l:line, '[')[1], ']')[0]
  else
    return v:null
  endif
endfunction

function! s:ChangeState(char)
  let save = winsaveview()
  let search_reg = <SID>SaveReg("/")
  let state = <SID>GetCurrentStateChar()
  if l:state != a:char
    call <SID>SetTodoState(a:char)
  endif
  call <SID>RestoreReg("/", l:search_reg)
  call winrestview(l:save)
endfunction

function! s:CycleTodoState()
  let save = winsaveview()
  let search_reg = <SID>SaveReg("/")
  let state = <SID>GetCurrentStateChar()
  if l:state is v:null
  elseif l:state == ' '
    call <SID>SetTodoState('\~')
  elseif l:state == '~'
    call <SID>SetTodoState('\/')
  elseif l:state == '/'
    call <SID>SetTodoState('0')
  elseif l:state == '0'
    call <SID>SetTodoState('?')
  elseif l:state == '?'
    call <SID>SetTodoState('x')
  else
    call <SID>SetTodoState(' ')
  endif
  call <SID>RestoreReg("/", l:search_reg)
  call winrestview(l:save)
endfunction

function! s:SetupTodoFile()
  setlocal filetype=markdown.todo

  " Map <CR> to make more or walk up the hierarchy
  imap <silent> <buffer> <expr> <CR> <SID>PerformAppropriateCR()

  " Map `o` to work like above
  nmap <silent> <buffer> o A<CR>
  nmap <silent> <buffer> O kA<CR>

  " <C-X> to toggle done/not-done
  " NB: overrides <C-x> used for decrement
  nmap <silent> <buffer> <C-x> :call <SID>ChangeState('x')<CR>
  imap <silent> <buffer> <C-x> <Esc>:call <SID>ChangeState('x')<CR>a

  " <C-\> to toggle done/not-done
  nmap <silent> <buffer> <C-\> :call <SID>CycleTodoState()<CR>
  imap <silent> <buffer> <C-\> <Esc>:call <SID>CycleTodoState()<CR>a

  " <C-\> to toggle done/not-done
  nmap <silent> <buffer> <C-Space> :call <SID>ChangeState(' ')<CR>
  imap <silent> <buffer> <C-Space> <Esc>:call <SID>ChangeState(' ')<CR>a

  " <C-F> focus on a cluster of TODOs
  nmap <silent> <buffer> <C-F> :call FocusOnCurrent()<CR>
  imap <silent> <buffer> <C-F> <Esc>:call FocusOnCurrent()<CR>a

  " Indent/Outdent
  nmap <silent> <buffer> <Tab> :call <SID>PerformAppropriateDent(1)<CR>
  imap <silent> <buffer> <Tab> <Esc>:call <SID>PerformAppropriateDent(1)<CR>a
  nmap <silent> <buffer> <S-Tab> :call <SID>PerformAppropriateDent(0)<CR>
  imap <silent> <buffer> <S-Tab> <Esc>:call <SID>PerformAppropriateDent(0)<CR>a

  " Indent wrapped lines up to the same level
  if exists('&breakindent')
    setlocal breakindent

    " shift wrapped content 6 spaces (g:todo_note_indent)
    setlocal breakindentopt=shift:6,sbr
    setlocal showbreak=

    " break at words
    setlocal linebreak

    " fold everything
    setlocal foldenable
  endif
endfunction

autocmd BufNewFile,BufRead todo-*.md call <SID>SetupTodoFile()
