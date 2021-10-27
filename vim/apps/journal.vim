" Source main `vim`

let g:app_plugin_set = 'journal'
exec "source" $DOT_FILES_DIR . "/" . "vim/includes/core.vim"

"{{{ Basics

" turn off all gutter stuff
set nolist
set nonumber
set norelativenumber

" special tab-size
set tabstop=4
set shiftwidth=4

"}}}


"{{{ Plugin-specific settings

" -- vim-autoclose --

if IsPluginLoaded('Townk/vim-autoclose')
  let g:AutoClosePairs_del = "[]"
endif

" -- airline --

if IsPluginLoaded('vim-airline/vim-airline')
  let g:airline#extensions#tabline#enabled = 0
endif

" -- golden-ratio --

if IsPluginLoaded('roman/golden-ratio')
  let g:golden_ratio_autocommand=1
endif

"}}}


"{{{ Paths

function! s:TodoPath()
  return $JOURNAL_PATH . '/todo.md'
endfunction

function! s:NewMenuPath()
  return $JOURNAL_PATH . '/new_menu.txt'
endfunction

"}}}


"{{{ Focus on Things

function! FocusOnCurrent()
  let save_cursor = getpos('.')
  let current_line = getline('.')
  if l:current_line =~ '^#\s.*$'
    execute 'normal! zM' . l:save_cursor[1] . 'GzO'
  else
    execute 'normal! zM' . l:save_cursor[1] . 'GzozO'
  endif
  call setpos('.', l:save_cursor)
endfunction

" TODO remove?
function! UnfoldDefault()
  let current_search = @/
  let @/ = '(DEFAULT)'
  normal! ggn
  call FocusOnCurrent()
  let @/ = l:current_search
endfunction

"}}}


"{{{ File Management

command SyncJournalAsync writeall | call system($JOURNAL_PATH . '/system/sync_journal.sh journal.vim')
command SyncJournal writeall | call system($JOURNAL_PATH . '/system/sync_journal.sh journal.vim --now')

function! s:LoadJournal()
  execute 'cd' $JOURNAL_PATH

  syntax enable
  filetype on
  filetype plugin on

  let g:markdown_fold_style = 'nested'
endfunction

"}}}


"{{{ Autogroups

augroup SetupJournal
  autocmd VimEnter * call s:LoadJournal()
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
imap <silent> <M-h> <C-O>:wincmd h<CR>
imap <silent> <M-j> <C-O>:wincmd j<CR>
imap <silent> <M-k> <C-O>:wincmd k<CR>
imap <silent> <M-l> <C-O>:wincmd l<CR>

" Q does nothing
nnoremap <silent> Q <Nop>

"}}}

