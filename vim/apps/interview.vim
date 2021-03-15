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


"{{{ Functions used below

let g:line_begins_with_prefix = '^\s*-\(\s\[[0-9][0-9]:[0-9][0-9]\]\)\?\s*'
let g:line_is_prefix = g:line_begins_with_prefix . '$'

function! CursorAfterLinePrefix()
  let line = getline('.')
  if l:line =~ g:line_is_prefix
    return 1
  else
    let cursor = getpos('.')
    let line_to_cursor = l:line[0:(l:cursor[2] - 2)]

    " -2 assumes insert mode:
    " * -1 because insert mode column = character after cursor
    " * -1 because columns are 1-indexed (not 0)
    if cursor[2] < 2 || l:line_to_cursor =~ g:line_is_prefix
      return 1
    else
      return 0
    endif
  endif
endfunction

function! InterviewDeleteCharacter()
  if CursorAfterLinePrefix()
    if line('.') == 1
      " first line, delete this line only
      return "\<Esc>v0\"_di"
    elseif len(substitute(getline(line('.')), g:line_begins_with_prefix, '', '')) > 0
      " non-empty line, use `i`
      return "\<Esc>vk$\"_di"
    else
      " non-empty line, use `a`
      return "\<Esc>vk$\"_da"
    endif
  else
    return "\<BS>"
  endif
endfunction

"}}}


"{{{ Enable/Disable Timestamping

let g:interview_timestamps_enabled = 0

function! ToggleTimestamps(...)
  if a:0 == 0
    if g:interview_timestamps_enabled
      iunmap <CR>
      nunmap O
      nunmap o
      iunmap <BS>

      let g:interview_timestamps_enabled = 0
      echo "Timestamps DISABLED"
    else
      inoremap <silent> <CR> <CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
      nnoremap <silent> O <Esc>kA<CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
      nnoremap <silent> o <Esc>A<CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
      inoremap <expr> <BS> InterviewDeleteCharacter()

      let g:interview_timestamps_enabled = 1
      echo "Timestamps ENABLED"
    end
  else
    if a:1 != g:interview_timestamps_enabled
      call ToggleTimestamps()
    end
  end
endfunction

command EnableTimestamps call ToggleTimestamps(1)
command DisableTimestamps call ToggleTimestamps(0)
command ToggleTimestamps call ToggleTimestamps()

"}}}


"{{{ On Load

function! s:SetupInterviewBuffer()
  " Desired `highlight` in comments
  syntax match helpfulMarkerXX /(XX)/
  syntax match helpfulMarkerYY /(YY)/
  syntax match helpfulMarkerZZ /(ZZ)/

  syntax cluster SubHighlights contains=markdownCode

  syntax cluster SubHighlights add=markdownBold
  syntax cluster SubHighlights add=markdownBoldDelimiter
  syntax cluster SubHighlights add=markdownItalic
  syntax cluster SubHighlights add=markdownItalicDelimiter

  syntax cluster SubHighlights add=helpfulMarkerXX
  syntax cluster SubHighlights add=helpfulMarkerYY
  syntax cluster SubHighlights add=helpfulMarkerZZ

  highlight default helpfulMarkerXX cterm=bold ctermfg=white ctermbg=darkblue
  highlight default helpfulMarkerYY cterm=bold ctermfg=white ctermbg=darkgreen
  highlight default helpfulMarkerZZ cterm=bold ctermfg=white ctermbg=darkcyan

  syntax match interviewerSaid /\c\<i:/
  syntax match candidateSaid /\c\<c:/
  syntax match interviewerNote /\c\<note:/
  syntax match interviewerHint /\c\<hint\>/

  syntax match quote /".\{-}"/ contains=@SubHighlights

  highlight default link interviewerSaid GruvboxGreenBold
  highlight default link candidateSaid GruvboxBlueBold
  highlight default interviewerNote cterm=bold,italic ctermfg=white
  highlight default interviewerHint cterm=bold,italic ctermfg=white ctermbg=darkred
  highlight default link quote GruvboxOrangeBold
endfunction

au FileType markdown call s:SetupInterviewBuffer()

"}}}


"{{{ On Load

function! s:LoadInterview()
  execute 'cd' $JOURNAL_PATH

  syntax enable
  filetype on
  filetype plugin on

  AutoSaveToggle

  set spell
  set spelllang=en

  EnableTimestamps

  nnoremap <silent> <F1> :<C-U>ToggleTimestamps<CR>
  inoremap <silent> <F1> <Esc>:<C-U>ToggleTimestamps<CR>a

  " default enter behavior always with meta enter
  inoremap <silent> <M-CR> <CR>

  " default enter behavior always with meta enter
  nnoremap <silent> <C-A> mm0f]h<C-A>`m
  nnoremap <silent> <C-X> mm0f]h<C-X>`m

  call s:SetupInterviewBuffer()
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

