" Setup any bindings for Journal buffer
function! s:SetupJournalFile()
  setlocal filetype=markdown.journal

  " <C-X> to indicate journal entry is complete
  " NB: overrides <C-x> used for decrement
  nmap <silent> <buffer> <C-x> Go<CR><!-- EOM --><Esc>:w<CR>:bd<CR>
  imap <silent> <buffer> <C-x> <Esc>Go<CR><!-- EOM --><Esc>:w<CR>:bd<CR>

  " unfold the entire doc
  nmap <silent> <buffer> <C-F> zR
  imap <silent> <buffer> <C-F> <Esc>'mzRamm

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

  exec "source" $DOT_FILES_DIR . "/" . "vim/includes/writing_highlights.vim"
endfunction

autocmd BufNewFile,BufRead journal-*.md call <SID>SetupJournalFile()
