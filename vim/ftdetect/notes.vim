function! s:PerformAppropriateCR()
  let line=getline('.')
  if l:line =~ '^\s\+-\s*$'
    return "\<Esc>\<S-Tab>A"
  elseif l:line =~ '^-\s*$'
    return "\<Esc>0C## "
  elseif l:line =~ '^\s*-.\+$'
    return "\<CR>-\<Space>"
  elseif l:line =~ '^##\s*$'
    return "\<Esc>0C# "
  elseif l:line =~ '^#\s*$'
    return "\<Esc>O\<Esc>0DjA"
  elseif l:line =~ '^#.*$'
    return "\<CR>-\<Space>"
  else
    return "\<CR>"
  endif
endfunction

function! s:PerformAppropriateDent(indent)
  let [bufnum, row, column, ignore] = getpos('.')
  let indent_amount = 0
  if (a:indent)
    normal >>
    let indent_amount = 4
  else
    let original_indent_amount = indent('.')
    normal <<
    if (l:original_indent_amount > 0)
      let indent_amount = -4
    endif
  endif
  call setpos('.', [bufnum, row, column + indent_amount, ignore])
endfunction

function! s:SetupNotesFile()
  setlocal filetype=markdown.notes

  " Map <CR> to make more or walk up the hierarchy
  imap <silent> <buffer> <expr> <CR> <SID>PerformAppropriateCR()

  " Map `o` to work like above
  nmap <silent> <buffer> o A<CR>
  nmap <silent> <buffer> O kA<CR>

  " Indent/Outdent
  nmap <silent> <buffer> <Tab> :call <SID>PerformAppropriateDent(1)<CR>
  imap <silent> <buffer> <Tab> <Esc>:call <SID>PerformAppropriateDent(1)<CR>a
  nmap <silent> <buffer> <S-Tab> :call <SID>PerformAppropriateDent(0)<CR>
  imap <silent> <buffer> <S-Tab> <Esc>:call <SID>PerformAppropriateDent(0)<CR>a

  " <C-F> focus on a cluster of notes
  nmap <silent> <buffer> <C-F> :call FocusOnCurrent()<CR>
  imap <silent> <buffer> <C-F> <Esc>:call FocusOnCurrent()<CR>a

  " Indent wrapped lines up to the same level
  if exists('&breakindent')
    setlocal breakindent

    " shift wrapped content 2 spaces
    setlocal breakindentopt=shift:2,sbr
    setlocal showbreak=

    " break at words
    setlocal linebreak

    " fold everything
    setlocal foldenable
  endif
endfunction

autocmd BufNewFile,BufRead notes-*.md call <SID>SetupNotesFile()
autocmd BufNewFile,BufRead log-current.md call <SID>SetupNotesFile()
