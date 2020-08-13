" Source main `vim`

let g:app_plugin_set = 'interview'
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

" -- airline --

if IsPluginLoaded('vim-airline/vim-airline')
  let g:airline#extensions#tabline#enabled = 0
endif

"}}}


"{{{ File Management

command SyncJournalAsync call system($JOURNAL_PATH . '/system/sync_journal.sh journal.vim')
command SyncJournal call system($JOURNAL_PATH . '/system/sync_journal.sh journal.vim --now')

"}}}


"{{{ On Load

function! s:LoadInterview()
  execute 'cd' $JOURNAL_PATH

  syntax enable
  filetype on
  filetype plugin on

  AutoSaveToggle

  set spellang=en
  set spell

  inoremap <silent> <CR> <CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
  nnoremap <silent> O <Esc>kA<CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
  nnoremap <silent> o <Esc>A<CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
endfunction

"}}}


"{{{ Autogroups

augroup SetupJournal
  autocmd VimEnter * call <SID>LoadInterview()
  autocmd VimLeave * SyncJournal
  autocmd FocusGained * SyncJournalAsync
  autocmd InsertLeave * SyncJournalAsync
augroup END

"}}}

