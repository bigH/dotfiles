if exists('g:custom_modal_tabs')
  finish
endif
let g:custom_modal_tabs = 1

" TODO import this

" 0 = no tabs
" 1 = tabs

let tab_mode = 0

func! ModalTabsApply()
  if g:tab_mode == 0
    set expandtab
  else
    set noexpandtab
  endif
  return
endfunc

func! ModalTabsRotate()
  let g:tabs_mode = (g:tabs_mode + 1) % 2
  call ModalTabsApply()
endfunc

" <F10> to rotate paste-mode
nnoremap <silent> <F5> :call ModalTabsRotate()<CR>

" Set on VimEnter
autocmd VimEnter * call ModalTabsApply()

"}}}
