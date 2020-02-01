function! s:PerformAppropriateCR()
  let line=getline('.')
  if l:line =~ '^\s\+-\s*$'
    return "\<Esc>\<S-Tab>A"
  elseif l:line =~ '^-\s*$'
    return "\<Esc>0C"
  elseif l:line =~ '^\s*-.\+$'
    return "\<CR>-\<Space>"
  else
    return "\<CR>"
  endif
endfunction

function! s:SetupNotesFile()
  setlocal filetype=markdown.notes

  " Map <CR> to make more or walk up the hierarchy
  imap <silent> <buffer> <expr> <CR> <SID>PerformAppropriateCR()

  " Indent/Outdent
  nmap <silent> <buffer> <Tab> mm>>`m4l
  imap <silent> <buffer> <Tab> <Esc>mm>>`m4la
  nmap <silent> <buffer> <S-Tab> mm<<`m4h
  imap <silent> <buffer> <S-Tab> <Esc>mm<<`m4ha

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
