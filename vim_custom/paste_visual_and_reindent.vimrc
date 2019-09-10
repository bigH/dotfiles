if exists('g:paste_visual_and_reindent')
  finish
endif
let g:paste_visual_and_reindent = 1

function! s:NumLinesSelected()
  let line_start = getpos("'<")[1]
  let line_end = getpos("'>")[1]

  if b:paste_visual_and_reindent_num_lines >= 0
    throw ("Expected `paste_visual_and_reindent_num_lines` to be negative; ".
    "This indicates a bug with `paste_visual_and_reindent`.")
  endif

  let b:paste_visual_and_reindent_num_lines = 1 + l:line_end - l:line_start
endfunction

function! s:IndentLinesYanked()
  if b:paste_visual_and_reindent_num_lines < 0
    throw ("Expected `paste_visual_and_reindent_num_lines` to be positive; ".
           "This indicates a bug with `paste_visual_and_reindent`.")
  endif

  execute 'normal' ('='.b:paste_visual_and_reindent_num_lines.'j<C-o>')
endfunction

vnoremap <Plug>VisualPasteAndReindent :call NumLinesSelected()<CR>p:call IndentLinesYanked()<CR><C-o>

" TODO make sure this works
if !exists("g:paste_visual_and_reindent_no_mappings") || ! g:paste_visual_and_reindent_no_mappings
  vnoremap p <Plug>VisualPasteAndReindent
  vnoremap P <Plug>VisualPasteAndReindent
endif
