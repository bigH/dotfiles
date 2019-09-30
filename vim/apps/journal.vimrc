" Source main `vimrc`

let g:app_plugin_set = 'journal'
exec "source" $DOT_FILES_DIR . "/vim/includes/core.vimrc"

"{{{ Basics

" override nowrap - vertical splits
set wrap

" turn off all gutter stuff
set nolist
set nonumber
set norelativenumber

"}}}


"{{{ Paths

function! s:IsWeekday()
  let day = strftime('%a')
  if day ==? 'sat' || day? == 'sun'
    return 0
  else
    return 1
  endif
endfunction

function! s:LastFileWritten(pattern)
  return trim(system('ls -t ' . $JOURNAL_PATH . '/' . a:pattern . '-* | head -1'))
endfunction

function! s:WeekdayFile(pattern)
  if s:IsWeekday()
    return ($JOURNAL_PATH . '/' . a:pattern . '-' . strftime('%Y-%m-%d'))
  else
    return s:LastFileWritten(a:pattern)
  endif
endfunction

function! s:TodoPath()
  let last_file = s:LastFileWritten('todo')
  let current_file = s:WeekdayFile('todo')
  if l:current_file == l:last_file
    return l:last_file
  else
    call system('cp "' . l:last_file . '" "' . l:current_file . '"')
    return l:last_file
  endif
endfunction

function! s:DailyJournalPath()
  return s:WeekdayFile('journal')
endfunction

function! s:NotesPath()
  return ($JOURNAL_PATH . '/' . 'notes-' . strftime('%Y-%m'))
endfunction

"}}}


"{{{ File Management

function! s:SyncRead()
  " git things
endfunction

function! s:SyncWrite()
  " git things
endfunction

function! s:RefreshJournal()
  call s:SyncRead()
  call s:SyncWrite()
endfunction

function! s:LoadJournal()
  cd $JOURNAL_PATH
  call AutoSaveToggle()
  execute 'edit' s:TodoPath()
  execute 'vsplit' s:DailyJournalPath()
  execute 'vsplit' s:NotesPath()
endfunction

"}}}


"{{{ Autogroups

augroup SetupLoader
  autocmd VimEnter * call s:LoadJournal()
  autocmd BufWritePost * call s:RefreshJournal()
  autocmd FocusGained * call s:RefreshJournal()
augroup END

"}}}
