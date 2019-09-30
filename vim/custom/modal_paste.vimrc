if exists('g:modal_paste')
  finish
endif
let g:modal_paste = 1


"{{{ Line Number and Paste Cycle

let paste_mode = 0 " 0 = relative, 1 = paste, 2 = absolute

func! Paste_on_off()
  if g:paste_mode == 0
    nnoremap <silent> k k
    nnoremap <silent> j j
    sign unplace *
    set paste
    set nonumber
    set norelativenumber
    set nolist
    let g:break_here_should_reformat=0
    let g:paste_mode = 1
  elseif g:paste_mode == 1
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    retab
    set nopaste
    set number
    set norelativenumber
    set list
    let g:break_here_should_reformat=1
    let g:paste_mode = 2
  else
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    retab
    set nopaste
    set number
    set relativenumber
    set list
    let g:break_here_should_reformat=1
    let g:paste_mode = 0
  endif
  return
endfunc

" Paste Mode!  Dang! <F10>

nnoremap <silent> <F10> :call Paste_on_off()<CR>

"}}}
