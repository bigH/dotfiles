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

function! IsWeekday()
  let day = strftime('%a')
  if day == 'Sat' || day == 'Sun'
    return 0
  else
    return 1
  endif
endfunction

function! LastFileWritten(pattern)
  return trim(system('ls -t ' . $JOURNAL_PATH . '/' . a:pattern . '-* | head -1'))
endfunction

function! DailyFile(pattern)
  return ($JOURNAL_PATH . '/' . a:pattern . '-' . strftime('%Y-%m-%d') . '.md')
endfunction

function! MonthlyFile(pattern)
  return ($JOURNAL_PATH . '/' . a:pattern . '-' . strftime('%Y-%m') . '.md')
endfunction

function! WeekdayFile(pattern)
  if IsWeekday()
    return DailyFile(a:pattern)
  else
    return LastFileWritten(a:pattern)
  endif
endfunction

function! TodoPath()
  let l:file = WeekdayFile('todo')
  if !filereadable(l:file)
    call system('ruby ' . $JOURNAL_PATH . '/system/todo.rb > ' . l:file)
  endif
  return l:file
endfunction

function! DailyJournalPath()
  let l:file = WeekdayFile('journal')
  if !filereadable(l:file)
    call system('ruby ' . $JOURNAL_PATH . '/system/journal.rb > ' . l:file)
  endif
  return l:file
endfunction

function! NotesPath()
  return MonthlyFile('notes')
endfunction

"}}}


"{{{ File Management

function! SyncRead()
  " git things
endfunction

function! SyncWrite()
  " git things
endfunction

function! RefreshJournal()
  call SyncRead()
  call SyncWrite()
endfunction

function! LoadJournal()
  syntax enable
  filetype on
  filetype plugin on

  execute 'cd' $JOURNAL_PATH
  call AutoSaveToggle()

  execute 'edit' TodoPath()
  execute 'filetype' 'detect'
  execute 'vsplit' DailyJournalPath()
  execute 'filetype' 'detect'
  execute 'vsplit' NotesPath()
  execute 'filetype' 'detect'

  execute 'wincmd' 'h'
  execute 'wincmd' 'h'
endfunction

"}}}


"{{{ Autogroups

augroup SetupLoader
  autocmd VimEnter * call LoadJournal()
  autocmd BufWritePost * call RefreshJournal()
  autocmd FocusGained * call RefreshJournal()
augroup END

"}}}


"{{{ Mappings

" Move between windows using <C-H/L> keys
nmap <silent> <C-H> :wincmd h<CR>
nmap <silent> <C-L> :wincmd l<CR>

" Move between windows using H/L keys
nmap <silent> H :wincmd h<CR>
nmap <silent> L :wincmd l<CR>

" Move between windows using <M-H/J/K/L> keys
nmap <silent> <M-h> :wincmd h<CR>
nmap <silent> <M-j> :wincmd j<CR>
nmap <silent> <M-k> :wincmd k<CR>
nmap <silent> <M-l> :wincmd l<CR>

" Move between windows using <M-H/J/K/L> keys
imap <silent> <M-h> <Esc>:wincmd h<CR>i
imap <silent> <M-j> <Esc>:wincmd j<CR>i
imap <silent> <M-k> <Esc>:wincmd k<CR>i
imap <silent> <M-l> <Esc>:wincmd l<CR>i

" Q does nothing
nnoremap <silent> Q <Nop>

"}}}
