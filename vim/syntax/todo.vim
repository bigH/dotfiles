highlight TodoTag        ctermfg=magenta  cterm=bold

highlight TodoNoAction   ctermfg=white
highlight TodoInProgress ctermfg=cyan
highlight TodoSomeAction ctermfg=cyan     cterm=bold
highlight TodoBlocked    ctermfg=darkred  cterm=bold
highlight TodoDropped    ctermfg=gray     cterm=bold
highlight TodoDone       ctermfg=gray

syntax match TodoTag contained /:[a-z_]\+/

syntax region TodoNoAction     start="^\s*- \[ \]"  end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoInProgress   start="^\s*- \[\~\]" end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoSomeAction   start="^\s*- \[\/\]" end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoBlocked      start="^\s*- \[?\]"  end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline

" below highlights should not highlight anything within the region
syntax region TodoDropped      start="^\s*- \[0\]"  end="$" contains=TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoDone         start="^\s*- \[x\]"  end="$" contains=TodoTag,markdownAutomaticLink keepend oneline
