" Source main `vim`

let g:app_plugin_set = 'interview'
exec "source" $DOT_FILES_DIR . "/" . "vim/includes/core.vim"

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

let g:line_begins_with_prefix = '^-\(\s\[[0-9][0-9]:[0-9][0-9]\]\)\?\s*'
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

function! InterviewCarriageReturn()
  let line = getline('.')
  if l:line =~ g:line_is_prefix
    return "\<Esc>0C- [\<C-R>=trim(system('date +%I:%M'))\<CR>]\<Space>"
  else
    return "\<CR>- [\<C-R>=trim(system('date +%I:%M'))\<CR>]\<Space>"
  endif
endfunction

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
      inoremap <silent> <expr> <CR> InterviewCarriageReturn()
      " <CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
      nnoremap <silent> O <Esc>kA<CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
      nnoremap <silent> o <Esc>A<CR>- [<C-R>=trim(system('date +%I:%M'))<CR>]<Space>
      inoremap <silent> <expr> <BS> InterviewDeleteCharacter()

      let g:interview_timestamps_enabled = 1
      echo "Timestamps ENABLED"
    end
  else
    if a:1 != g:interview_timestamps_enabled
      call ToggleTimestamps()
    end
  end
endfunction

function! UpdateTimestamp(amount)
  let line = getline('.')
  if l:line =~ g:line_begins_with_prefix
    let cursor = getpos('.')

    let m = str2nr(l:line[6:7]) + a:amount
    let h = str2nr(l:line[3:4])

    if l:m >= 60
      let m = l:m - 60
      let h = l:h + 1
      if l:h > 12
        let h = 1
      endif
    elseif l:m < 0
      let m = l:m + 60
      let h = l:h - 1
      if l:h < 1
        let h = 12
      endif
    endif

    let g:last_info = l:h . ':' . l:m

    call setline(line('.'), '- [' . printf('%02d', l:h) . ':' . printf('%02d', l:m) . '] ' . l:line[10:])
  endif
endfunction

"}}}


"{{{ Enable/Disable Timestamping

command EnableTimestamps call ToggleTimestamps(1)
command DisableTimestamps call ToggleTimestamps(0)
command ToggleTimestamps call ToggleTimestamps()

command IncrementTimestamp call UpdateTimestamp(1)
command DecrementTimestamp call UpdateTimestamp(-1)

"}}}


"{{{ On Load

function! s:SetupInterviewBuffer()
  " Desired `highlight` in comments
  exec "source" $DOT_FILES_DIR . "/" . "vim/includes/writing_highlights.vim"

  syntax match interviewerHint /\c\<hint\(ed\|ing\|s\|\)\>/
  syntax match interviewerExplain /\c\<explain\(ed\|ing\|s\|\)\>/

  highlight default interviewerHint cterm=bold,italic ctermfg=black ctermbg=red
  highlight default interviewerExplain cterm=bold,italic ctermfg=black ctermbg=yellow

  syntax match helpfulMarkerXX /(XX)/
  syntax match helpfulMarkerYY /(YY)/
  syntax match helpfulMarkerZZ /(ZZ)/

  highlight default helpfulMarkerXX cterm=bold ctermfg=white ctermbg=darkblue
  highlight default helpfulMarkerYY cterm=bold ctermfg=white ctermbg=darkgreen
  highlight default helpfulMarkerZZ cterm=bold ctermfg=white ctermbg=darkcyan

  syntax match timestamp /\[[0-9][0-9]:[0-9][0-9]\]/

  highlight default link timestamp GruvboxGray

  syntax cluster SubHighlights contains=timestamp

  syntax cluster SubHighlights add=helpfulMarkerXX
  syntax cluster SubHighlights add=helpfulMarkerYY
  syntax cluster SubHighlights add=helpfulMarkerZZ

  syntax cluster SubHighlights add=interviewerHint
  syntax cluster SubHighlights add=interviewerExplain

  syntax cluster SubHighlights add=weaselyWords
  syntax cluster SubHighlights add=passiveyWords

  syntax cluster SubHighlights add=markdownBold
  syntax cluster SubHighlights add=markdownBoldDelimiter
  syntax cluster SubHighlights add=markdownItalic
  syntax cluster SubHighlights add=markdownItalicDelimiter

  syntax cluster SubHighlights add=markdownCode

  syntax match interviewerSaid /\c\<i:/
  syntax match candidateSaid /\c\<c:/
  syntax match interviewerNote /\c\<note:/

  highlight default link interviewerSaid GruvboxGreenBold
  highlight default link candidateSaid GruvboxBlueBold
  highlight default interviewerNote cterm=bold,italic ctermfg=white

  syntax match quote2 /".\{-}"/ contains=@SubHighlights

  highlight default link quote2 GruvboxPurpleBold

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
  inoremap <silent> <F1> <C-O>:<C-U>ToggleTimestamps<CR>

  " default enter behavior always with meta enter
  inoremap <silent> <M-CR> <CR>

  " C-A increment time
  nnoremap <silent> <C-A> :<C-U>IncrementTimestamp<CR>
  inoremap <silent> <C-A> <C-O>:<C-U>IncrementTimestamp<CR>

  " C-X decrement time
  nnoremap <silent> <C-X> :<C-U>DecrementTimestamp<CR>
  inoremap <silent> <C-X> <C-O>:<C-U>DecrementTimestamp<CR>

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

