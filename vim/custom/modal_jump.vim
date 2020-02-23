if exists('g:custom_modal_jump')
  finish
endif
let g:custom_modal_jump = 1

"{{{ Cycle <C-J> and <C-K> functionality

" TODO
" - highlight previous line when you move lines
" - make it so when switching tabs in a loclist or quickfix mode, we jump to
"   the first error after switching files (aucmd?)

" 0 = git hunks
" 1 = quickfix
" 2 = loc-list
" 3 = methods
" 4 = classes
let s:jk_mode_for_loclist = 2
let g:jk_mode = 0

function! COpenIfApplicable(jump_to_first)
  let current_window = winnr()
  let current_buffer = bufname()
  " close the other one
  lclose
  copen
  wincmd J
  if a:jump_to_first && len(getqflist()) > 0
    cfirst
    wincmd k
  elseif buflisted(l:current_buffer)
    execute current_window . 'wincmd w'
  else
    wincmd k
  endif
endfunc

function! LOpenIfApplicable(jump_to_first)
  let current_window = winnr()
  let current_buffer = bufname()
  " close the other one
  cclose
  lopen
  wincmd J
  if a:jump_to_first && len(getloclist(l:current_buffer)) > 0
    lfirst
  elseif buflisted(l:current_buffer)
    execute current_window . 'wincmd w'
  else
    wincmd k
  endif
endfunc

function! CloseBothLists()
  cclose
  lclose
endfunc

function! JKModeApply()
  if g:jk_mode == 0
    call CloseBothLists()
    echo "=> Git Hunk Mode"
  elseif g:jk_mode == 1
    call COpenIfApplicable(1)
    echo "=> QuickFix Mode"
  elseif g:jk_mode == 2
    call LOpenIfApplicable(1)
    wincmd k
    echo "=> Loc List Mode"
  elseif g:jk_mode == 3
    call CloseBothLists()
    echo "=> Method Mode"
  else
    call CloseBothLists()
    echo "=> Class Mode"
  endif
endfunc

function! Modulus(n,m)
  return (a:n + a:m) % a:m
endfunc

function! JKModeRotate(direction)
  let g:jk_mode = Modulus(g:jk_mode + a:direction, 5)
  call JKModeApply()
endfunc

function! JKModeSet(mode)
  let g:jk_mode = Modulus(mode, 5)
  call JKModeApply()
endfunc

function! JKModeJ()
  if g:jk_mode == 1
    try
      cnext
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 2
    try
      lnext
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 3
    normal ]m
  elseif g:jk_mode == 4
    normal ]]
  else
    GitGutterNextHunk
  endif
endfunc

function! JKModeK()
  if g:jk_mode == 1
    try
      cprevious
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 2
    try
      lprevious
    catch /.*/
      " ignore the error
    endtry
  elseif g:jk_mode == 3
    normal [m
  elseif g:jk_mode == 4
    normal [[
  else
    GitGutterPrevHunk
  endif
endfunc

" function! UpdateLocListIfApplicable()
"   if g:jk_mode == s:jk_mode_for_loclist
"     call LOpenIfApplicable(0)
"   endif
" endfunction

" autocmd WinLeave * call RecordLastWindowLocList()
" autocmd WinEnter * call UpdateLocListIfApplicable()

" Rotate modes
nnoremap <silent> ]<leader>] :call JKModeRotate(1)<CR>
nnoremap <silent> <leader>] :call JKModeRotate(1)<CR>
nnoremap <silent> [<leader>[ :call JKModeRotate(-1)<CR>
nnoremap <silent> <leader>[ :call JKModeRotate(-1)<CR>

" Use <C-J/K> to move in current mode
nmap <silent> <C-J> :call JKModeJ()<CR>
nmap <silent> <C-K> :call JKModeK()<CR>

"}}}
