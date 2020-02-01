" Source main `vim`

let g:app_plugin_set = 'journal'
exec "source" $DOT_FILES_DIR . "/vim/includes/core.vim"

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


"{{{ Plugin-specific settings

let g:AutoClosePairs_del = "[]"

"}}}


"{{{ Paths

function! s:TodoPath()
  return $JOURNAL_PATH . '/todo-current.md'
endfunction

function! s:LatestDatedFile(pattern)
  return trim(system('ls ' . $JOURNAL_PATH . '/' . a:pattern . '-* | sort | tail -1'))
endfunction

function! s:NotesPath()
  return s:LatestDatedFile('notes')
endfunction

function! s:DailyJournalPath()
  return s:LatestDatedFile('journal')
endfunction

"}}}


"{{{ Focus on Things

function! s:FocusOnCurrentWhileKeepingHeader()
  let save_cursor = getpos('.')
  let current_line = getline('.')
  if l:current_line =~ '^#\s.*$'
    execute 'normal! zMgg' . l:save_cursor[1] . 'GzO'
  else
    execute 'normal! zMgg' . l:save_cursor[1] . 'GzozO'
  endif
  call setpos('.', l:save_cursor)
endfunction

nmap <silent> <C-f> :call <SID>FocusOnCurrentWhileKeepingHeader()<CR>
imap <silent> <C-f> <Esc>:call <SID>FocusOnCurrentWhileKeepingHeader()<CR>a

"}}}


"{{{ File Management

command SyncJournalAsync call system($JOURNAL_PATH . '/system/sync_journal.sh journal.vim')
command SyncJournal call system($JOURNAL_PATH . '/system/sync_journal.sh journal.vim --now')

function! s:LoadJournal()
  syntax enable
  filetype on
  filetype plugin on

  let g:markdown_fold_style = 'nested'
  let g:auto_save_postsave_hook = 'SyncJournalAsync'

  AutoSaveToggle

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

  SyncJournalAsync

  execute 'wincmd' 'h'
  execute 'wincmd' 'h'
endfunction

"}}}


"{{{ Autogroups

augroup SetupJournal
  autocmd VimEnter * call <SID>LoadJournal()
  autocmd VimLeave * SyncJournal
  autocmd FocusGained * SyncJournalAsync
  autocmd FocusLost * stopinsert
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
