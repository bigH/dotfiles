if exists('g:custom_modal_paste')
  finish
endif
let g:custom_modal_paste = 1


"{{{ Line Number and Paste Cycle

" 0 = paste mode
" 1 = relative numbers
" 2 = absolute numbers
let paste_mode = 1

func! ModalPasteApply()
  if g:paste_mode == 0
    nnoremap <silent> k k
    nnoremap <silent> j j
    sign unplace *
    set paste
    set nonumber
    set norelativenumber
    set nolist
    nunmap p
    nunmap P
    vunmap p
    vunmap P
    let g:break_here_should_reformat=0
  elseif g:paste_mode == 1
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    retab
    set nopaste
    set number
    set relativenumber
    set list
    nnoremap <silent> p mmp=`]`m
    nnoremap <silent> P mmP=`]`m
    vnoremap <silent> p p=']
    vnoremap <silent> P P=']
    let g:break_here_should_reformat=1
  else
    nnoremap <silent> k gk
    nnoremap <silent> j gj
    retab
    set nopaste
    set number
    set norelativenumber
    set list
    nnoremap <silent> p mmp=`]`m
    nnoremap <silent> P mmP=`]`m
    vnoremap <silent> p p=']
    vnoremap <silent> P P=']
    let g:break_here_should_reformat=1
  endif
  return
endfunc

func! ModalPasteRotate()
  let g:paste_mode = (g:paste_mode + 1) % 3
  call ApplyPasteMode()
endfunc

" <F10> to rotate paste-mode
nnoremap <silent> <F10> :call ModalPasteRotate()<CR>

" Set on VimEnter
autocmd VimEnter * call ModalPasteApply()

"}}}
