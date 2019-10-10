highlight TodoTag        ctermfg=magenta  cterm=bold

highlight TodoNoAction   ctermfg=white
highlight TodoInProgress ctermfg=cyan
highlight TodoSomeAction ctermfg=cyan cterm=bold
highlight TodoDropped    ctermfg=gray     cterm=bold
highlight TodoBlocked    ctermfg=darkred  cterm=bold
highlight TodoDone       ctermfg=gray

syntax match TodoTag contained /:[a-z_]\+/

syntax region TodoNoAction     start="^\s*- \[ \]"  end="$" contains=@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoInProgress   start="^\s*- \[\~\]" end="$" contains=@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoSomeAction   start="^\s*- \[\/\]" end="$" contains=@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoDropped      start="^\s*- \[0\]"  end="$" contains=@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoBlocked      start="^\s*- \[?\]"  end="$" contains=@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoDone         start="^\s*- \[x\]"  end="$" contains=@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
