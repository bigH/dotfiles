" Setup any bindings for Journal buffer
function! s:SetupJournalFile()
  set filetype=markdown.journal

  nmap <silent> <buffer> <C-x> GO<!-- EOM --><Esc>:w<CR>:bd<CR>
  imap <silent> <buffer> <C-x> <Esc>GO<!-- EOM --><Esc>:w<CR>:bd<CR>

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

autocmd BufNewFile,BufRead journal-*.md call <SID>SetupJournalFile()
