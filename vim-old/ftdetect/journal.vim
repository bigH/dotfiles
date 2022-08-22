" Setup any bindings for Journal buffer
function! s:SetupJournalFile()
  setlocal filetype=markdown.journal

j " Indent wrapped lines up to the same level
  if exists('&breakindent')
    setlocal breakindent

    " shift wrapped content 2 spaces
    setlocal breakindentopt=shift:2,sbr
    setlocal showbreak=

    " break at words
    setlocal linebreak
  endif

  exec "source" $DOT_FILES_DIR . "/" . "vim/includes/writing_highlights.vim"
endfunction

autocmd BufNewFile,BufRead journal-*.md call <SID>SetupJournalFile()
