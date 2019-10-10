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

" Setup any bindings for Journal buffer
function! s:SetupNotesFile()
  set filetype=markdown.notes

  " Map <CR> to make more TODOs
  imap <silent> <buffer> <expr> <CR> <SID>PerformAppropriateCR()

  " Move between windows using <C-H/L> keys
  nmap <silent> <buffer> <Tab> >>
  imap <silent> <buffer> <Tab> <Esc>mm>>`m4la
  nmap <silent> <buffer> <S-Tab> <<
  imap <silent> <buffer> <S-Tab> <Esc>mm<<`m4ha

  " Indent wrapped lines up to the same level
  if exists('&breakindent')
    set breakindent

    " shift wrapped content 2 spaces
    set breakindentopt=shift:2,sbr
    set showbreak=

    " break at words
    set linebreak
  endif
endfunction

autocmd BufNewFile,BufRead notes-*.md call <SID>SetupNotesFile()
