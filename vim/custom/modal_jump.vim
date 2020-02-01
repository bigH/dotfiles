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
let g:jk_mode = 0

func! COpenIfApplicable()
  " close the other one
  lclose
  if len(getqflist()) == 0
    cclose
  else
    copen
    cfirst
    wincmd k
  endif
endfunc

func! LOpenIfApplicable()
  " close the other one
  cclose
  if len(getloclist(winnr())) == 0
    lclose
  else
    lopen
    lfirst
    wincmd k
  endif
endfunc

func! CloseBothLists()
  cclose
  lclose
endfunc

func! JKModeApply()
  if g:jk_mode == 0
    call CloseBothLists()
    echo "=> Git Hunk Mode"
  elseif g:jk_mode == 1
    call COpenIfApplicable()
    echo "=> QuickFix Mode"
  elseif g:jk_mode == 2
    call LOpenIfApplicable()
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

func! Modulus(n,m)
  return ((a:n % a:m) + a:m) % a:m
endfunc

func! JKModeRotate(direction)
  let g:jk_mode = Modulus(g:jk_mode + a:direction, 5)
  call JKModeApply()
endfunc

func! JKModeJ()
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

func! JKModeK()
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

" Rotate modes
nnoremap <silent> ]<leader>] :call JKModeRotate(1)<CR>
nnoremap <silent> <leader>] :call JKModeRotate(1)<CR>
nnoremap <silent> [<leader>[ :call JKModeRotate(-1)<CR>
nnoremap <silent> <leader>[ :call JKModeRotate(-1)<CR>

" Use <C-J/K> to move in current mode
nmap <silent> <C-J> :call JKModeJ()<CR>
nmap <silent> <C-K> :call JKModeK()<CR>

" Use <M-J/K> when in insert mode to handle <C-J/K>
inoremap <silent> <M-j> <Esc><C-J>I
inoremap <silent> <M-k> <Esc><C-K>I

"}}}
