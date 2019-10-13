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

" special tab-size
set tabstop=4
set shiftwidth=4

"}}}


"{{{ Paths

function! s:LastFileWritten(pattern)
  return trim(system('ls -t ' . $JOURNAL_PATH . '/' . a:pattern . '-* | head -1'))
endfunction

function! s:TodoPath()
  return s:LastFileWritten('todo')
endfunction

function! s:DailyJournalPath()
  return s:LastFileWritten('journal')
endfunction

function! s:NotesPath()
  return s:LastFileWritten('notes')
endfunction

"}}}


"{{{ File Management

command SyncJournalAsync call system($JOURNAL_PATH . '/system/sync_journal.sh journal.vimrc')

function! s:LoadJournal()
  syntax enable
  filetype on
  filetype plugin on

  let g:auto_save_silent = 1
  let g:auto_save_postsave_hook = 'SyncJournalAsync'
  call AutoSaveToggle()

  let g:markdown_folding = 1
  set nofoldenable

  execute 'cd' $JOURNAL_PATH

  call system($JOURNAL_PATH . '/system/rejournal.sh')

  execute 'edit' s:TodoPath()
  execute 'filetype' 'detect'
  execute 'vsplit' s:NotesPath()
  execute 'filetype' 'detect'
  let journal_path = s:DailyJournalPath()
  if split(system('cat ' . l:journal_path), '\n')[-1] != '<!-- EOM -->'
    execute 'vsplit' l:journal_path
    execute 'filetype' 'detect'
  endif

  execute 'wincmd' 'h'
  execute 'wincmd' 'h'
endfunction

"}}}


"{{{ Autogroups

augroup SetupLoader
  autocmd VimEnter * call <SID>LoadJournal()
  autocmd FocusGained * SyncJournalAsync
augroup END

"}}}


"{{{ Mappings

" Move between windows using <C-H/L> keys
nmap <silent> <C-H> :wincmd h<CR>:wincmd h<CR>
nmap <silent> <C-L> :wincmd l<CR>:wincmd l<CR>

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
