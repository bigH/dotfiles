function! s:PerformAppropriateCR()
  let line=getline('.')
  if l:line =~ '^\s\+- \[ \]\s*$'
    return "\<Esc>\<S-Tab>A"
  elseif l:line =~ '^- \[ \]\s*$'
    return "\<Esc>0C# "
  elseif l:line =~ '^\s*- \[.\].\+$'
    return "\<CR>-\<Space>[\<Space>]\<Space>"
  elseif l:line =~ '^#\s*$'
    return "\<Esc>O\<Esc>jA"
  elseif l:line =~ '^#.*$'
    return "\<CR>-\<Space>[\<Space>]\<Space>"
  else
    return "\<CR>"
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

function! s:ToggleTodoStateAll()
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

function! s:ToggleTodoStateSimple()
  let save = winsaveview()
  let search_reg = <SID>SaveReg("/")
  let state = <SID>GetCurrentStateChar()
  if l:state is v:null
  elseif l:state == 'x'
    call <SID>SetTodoState(' ')
  else
    call <SID>SetTodoState('x')
  endif
  call <SID>RestoreReg("/", l:search_reg)
  call winrestview(l:save)
endfunction

function! s:SetupTodoFile()
  setlocal filetype=markdown.todo

  " Map <CR> to make more or walk up the hierarchy
  imap <silent> <buffer> <expr> <CR> <SID>PerformAppropriateCR()

  " <C-X> to toggle done/not-done
  " NB: overrides <C-x> used for decrement
  nmap <silent> <buffer> <C-x> :call <SID>ToggleTodoStateSimple()<CR>
  imap <silent> <buffer> <C-x> <Esc>:call <SID>ToggleTodoStateSimple()<CR>a

  " <C-\> to toggle done/not-done
  nmap <silent> <buffer> <C-\> :call <SID>ToggleTodoStateAll()<CR>
  imap <silent> <buffer> <C-\> <Esc>:call <SID>ToggleTodoStateAll()<CR>a

  " Indent/Outdent
  nmap <silent> <buffer> <Tab> mm>>`m4l
  imap <silent> <buffer> <Tab> <Esc>mm>>`m4la
  nmap <silent> <buffer> <S-Tab> mm<<`m4h
  imap <silent> <buffer> <S-Tab> <Esc>mm<<`m4ha

  " Indent wrapped lines up to the same level
  if exists('&breakindent')
    setlocal breakindent

    " shift wrapped content 6 spaces
    setlocal breakindentopt=shift:6,sbr
    setlocal showbreak=

    " break at words
    setlocal linebreak

    " fold everything
    setlocal foldenable
  endif
endfunction

autocmd BufNewFile,BufRead todo-*.md call <SID>SetupTodoFile()
