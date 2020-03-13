if exists('g:custom_modal_jump')
  finish
endif
let g:custom_modal_jump = 1

"{{{ Cycle <C-J> and <C-K> functionality

" TODO
" - highlight previous line when you move lines
" - make it so when switching tabs in a loclist or quickfix mode, we jump to
"   the first error after switching files (aucmd?)

let s:modes = ['Git Hunks',
        \      'Quickfix',
        \      'Loc List']

let g:jk_mode = 0

function! s:COpenIfApplicable(jump_to_first)
  let current_window = winnr()
  let current_buffer = bufname()
  copen
  wincmd J
  if a:jump_to_first && len(getqflist()) > 0
    cfirst
  endif
  execute current_window . 'wincmd w'
endfunc

function! s:LCloseIfPossible()
  if &buftype == 'locationlist'
    lclose
  endif
endfunc

function! s:LOpenFirstIfPossible(jump_to_first)
  if &buftype != "quickfix" && &buftype != "locationlist"
    lopen
    if a:jump_to_first && len(getloclist(winnr())) > 0
      lfirst
    endif
  endif
endfunc

function! s:LOpenIfApplicable(jump_to_first)
  let current_buffer = bufnr()
  " close the other one
  silent! cclose
  windo call s:LOpenFirstIfPossible(a:jump_to_first)
  let target_window = bufwinnr(l:current_buffer)
  execute l:target_window . 'wincmd w'
endfunc

function! s:CloseBothLists()
  silent! cclose
  " windo call s:LCloseIfPossible()
  let window_numbers = range(len(getwininfo()) - 1, 0, -1)
  for l:window in l:window_numbers
    if getwininfo()[l:window].loclist
      lclose
    endif
  endfor
endfunc

function! s:JKModeApply()
  let current = s:modes[g:jk_mode]
  if l:current == 'Git Hunks'
    call s:CloseBothLists()
  elseif l:current == 'Quickfix'
    call s:COpenIfApplicable(1)
  elseif l:current == 'Loc List'
    call s:LOpenIfApplicable(1)
  endif
  echo "=> " . l:current . " Mode"
endfunc

function! s:Modulus(n,m)
  return (a:n + a:m) % a:m
endfunc

function! s:JKModeSet(mode_number)
  let g:jk_mode = s:Modulus(a:mode_number, len(s:modes))
  call s:JKModeApply()
endfunc

function! s:JKModeRotate(direction)
  let g:jk_mode = s:Modulus(g:jk_mode + a:direction, len(s:modes))
  call s:JKModeSet(g:jk_mode)
endfunc

function! s:JKModeJ()
  let current = s:modes[g:jk_mode]
  if l:current == 'Git Hunks'
    GitGutterNextHunk
  elseif l:current == 'Quickfix'
    silent! cnext
  elseif l:current == 'Loc List'
    silent! lnext
  else
    echo "unknown mode: " . g:jk_mode
  endif
endfunc

function! s:JKModeK()
  let current = s:modes[g:jk_mode]
  if l:current == 'Git Hunks'
    GitGutterPrevHunk
  elseif l:current == 'Quickfix'
    silent! cprevious
  elseif l:current == 'Loc List'
    silent! lprevious
  else
    echo "unknown mode: " . g:jk_mode
  endif
endfunc

function! s:LOpenForNewWindow()
  let current = s:modes[g:jk_mode]
  if l:current == 'Loc List'
    call s:LOpenFirstIfPossible(1)
  endif
endfunc

" Doesn't work fully for some reason (maybe there's a bug in JKModeApply)
autocmd QuickFixCmdPost * call <SID>JKModeSet(1)

" Rotate modes
nnoremap <silent> ]<leader>] :<C-U>call <SID>JKModeRotate(1)<CR>
nnoremap <silent> <leader>] :<C-U>call <SID>JKModeRotate(1)<CR>
nnoremap <silent> [<leader>[ :<C-U>call <SID>JKModeRotate(-1)<CR>
nnoremap <silent> <leader>[ :<C-U>call <SID>JKModeRotate(-1)<CR>

" Use <C-J/K> to move in current mode
nmap <silent> <C-J> :<C-U>call <SID>JKModeJ()<CR>
nmap <silent> <C-K> :<C-U>call <SID>JKModeK()<CR>

"}}}
