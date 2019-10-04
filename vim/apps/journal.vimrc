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

function! LastFileWritten(pattern)
  return trim(system('ls -t ' . $JOURNAL_PATH . '/' . a:pattern . '-* | head -1'))
endfunction

function! TodoPath()
  return LastFileWritten('todo')
endfunction

function! DailyJournalPath()
  return LastFileWritten('journal')
endfunction

function! NotesPath()
  return LastFileWritten('notes')
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

  call system($JOURNAL_PATH . '/system/rejournal.sh')

  execute 'edit' TodoPath()
  execute 'filetype' 'detect'
  execute 'vsplit' DailyJournalPath()
  execute 'filetype' 'detect'
  execute 'vsplit' NotesPath()
  execute 'filetype' 'detect'

  call AutoSaveToggle()

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
