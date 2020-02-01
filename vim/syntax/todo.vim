highlight TodoTag        ctermfg=magenta  cterm=bold   gui=bold

highlight TodoNoAction   ctermfg=white
highlight TodoInProgress ctermfg=cyan
highlight TodoSomeAction ctermfg=cyan     cterm=bold   gui=bold
highlight TodoBlocked    ctermfg=darkred  cterm=bold   gui=bold
highlight TodoDropped    ctermfg=gray     cterm=bold   gui=bold
highlight TodoDone       ctermfg=gray

highlight TodoNotes      ctermfg=darkgrey ctermbg=none cterm=italic gui=italic

syntax match TodoTag contained /:[a-z_]\+/

syntax region TodoNoAction     start="^\s*- \[ \]"       end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoInProgress   start="^\s*- \[\~\]"      end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoSomeAction   start="^\s*- \[\/\]"      end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoBlocked      start="^\s*- \[?\]"       end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline

" below highlights should not highlight anything within the region
syntax region TodoDropped      start="^\s*- \[0\]"       end="$" contains=TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoDone         start="^\s*- \[x\]"       end="$" contains=TodoTag,markdownAutomaticLink keepend oneline

syntax region TodoNotes        start="^\(\s\s\s\s\)\+\(\s*- \[.\]\)\@!" end="$" keepend oneline

