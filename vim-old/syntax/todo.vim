highlight TodoTag        ctermfg=magenta  cterm=bold

highlight TodoNoAction   ctermfg=white                              guifg=white
highlight TodoInProgress ctermfg=cyan                               guifg=cyan
highlight TodoSomeAction ctermfg=cyan     cterm=bold                guifg=cyan     gui=bold
highlight TodoBlocked    ctermfg=darkred  cterm=bold                guifg=darkred  gui=bold
highlight TodoDropped    ctermfg=gray     cterm=bold                guifg=gray     gui=bold
highlight TodoDone       ctermfg=gray                               guifg=gray

highlight TodoNotes      ctermfg=darkgrey ctermbg=none cterm=italic guifg=darkgrey guibg=none gui=italic

syntax match TodoTag contained /:[a-z_]\+/

syntax region TodoNoAction     start="^\s*- \[ \]"       end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoInProgress   start="^\s*- \[\~\]"      end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoSomeAction   start="^\s*- \[\/\]"      end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoBlocked      start="^\s*- \[?\]"       end="$" contains=@markdownId,@markdownInline,TodoTag,markdownAutomaticLink keepend oneline

" below highlights should not highlight anything within the region
syntax region TodoDropped      start="^\s*- \[0\]"       end="$" contains=TodoTag,markdownAutomaticLink keepend oneline
syntax region TodoDone         start="^\s*- \[x\]"       end="$" contains=TodoTag,markdownAutomaticLink keepend oneline

syntax region TodoNotes        start="^\(\s\s\s\s\)\+\(\s*- \[.\]\)\@!" end="$" keepend oneline

highlight markdownItalic ctermfg=white cterm=italic guifg=white gui=italic
