if exists('g:highlight_cursor_word_installed')
  finish
endif
let g:highlight_cursor_word_installed = 1

function! s:NoHighlightCursorWordNow()
    if (exists("w:HighlightCursorWordMatchId") && w:HighlightCursorWordMatchId !=0)
        try
            call matchdelete(w:HighlightCursorWordMatchId)
        catch
        endt
        let w:HighlightCursorWordMatchId = 0
    endif
endfunction

function! s:HighlightCursorWordNow()
    if (exists("w:HighlightCursorWordMatchId") && w:HighlightCursorWordMatchId !=0)
        try
            call matchdelete(w:HighlightCursorWordMatchId)
        catch
        endt
        let w:HighlightCursorWordMatchId = 0
    endif

    let s:wordUnderCursor = expand("<cword>")

    if(exists("g:HighlightCursorWordHighlightSetting"))
        exe "highlight HighlightCursorWordHighlight " . g:HighlightCursorWordHighlightSetting
    else
        highlight HighlightCursorWordHighlight cterm=bold ctermfg=darkred
    endif

    try
        let w:HighlightCursorWordMatchId = matchadd('HighlightCursorWordHighlight', '\<'.s:wordUnderCursor.'\>', -1)
    catch /.*/
        echo "Couldn't HighlightCursorWordNow"
    endtry
endfunction

augroup HighlightCursorWordGroup
    autocmd!
    au CursorHold * call <sid>HighlightCursorWordNow()
    au CursorHoldI * call <sid>HighlightCursorWordNow()
augroup END

command! HighlightCursorWord :call <sid>HighlightCursorWordNow()

" TODO
"  - make an array of ignored words
"  - potentially support making it not clash with searches
