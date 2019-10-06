"{{{ Includes

exec "source" $DOT_FILES_DIR . "/vim/includes/core.vimrc"

exec "source" $DOT_FILES_DIR . "/vim/custom/modal_jump.vimrc"
exec "source" $DOT_FILES_DIR . "/vim/custom/modal_paste.vimrc"

"}}}


"{{{ AutoCommands

" Reload edited files.
augroup ReloadGitGutter
  autocmd FocusGained * GitGutterAll
  autocmd BufEnter * GitGutterAll
augroup end

" Remove any trailing whitespace that is in the file
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

"}}}


"{{{ Needed for UltiSnips

if IsPluginLoaded('SirVer/UltiSnips')
	" Setup Python
	let g:python2_host_prog = '/usr/local/bin/python'
	let g:python3_host_prog = '/usr/local/bin/python3'
endif

"}}}


"{{{ Pasting Only Useful in Code

" Re-indent when pasting
nnoremap p p=`]
nnoremap P P=`]

" Re-indent when pasting in visual mode
vnoremap p p=']
vnoremap P P=']

"}}}


"{{{ Window Management

" Kill current split
nmap <silent> <M-x> :close<CR>
imap <silent> <M-x> <Esc>:close<CR>

" Make current split the only
nmap <silent> <M-X> :only<CR>
imap <silent> <M-X> <Esc>:only<CR>

" Move between windows using <M-H/J/K/L> keys
nmap <silent> <M-h> :wincmd h<CR>
nmap <silent> <M-j> :wincmd j<CR>
nmap <silent> <M-k> :wincmd k<CR>
nmap <silent> <M-l> :wincmd l<CR>

" Move between windows using <M-H/J/K/L> keys
imap <silent> <M-h> <Esc>:wincmd h<CR>i
imap <silent> <M-j> <Esc>:wincmd j<CR>i
imap <silent> <M-k> <Esc>:wincmd k<CR>i
imap <silent> <M-l> <Esc>:wincmd l<CR>i

" Split windows using <M-S-H/J/K/L> keys
nmap <silent> <M-H> :vsplit<CR>:wincmd h<CR>
nmap <silent> <M-J> :split<CR>
nmap <silent> <M-K> :split<CR>:wincmd k<CR>
nmap <silent> <M-L> :vsplit<CR>

" Split windows using <M-S-H/J/K/L> keys
imap <silent> <M-H> <Esc>:vsplit<CR>:wincmd h<CR>i
imap <silent> <M-J> <Esc>:split<CR>i
imap <silent> <M-K> <Esc>:split<CR>:wincmd k<CR>i
imap <silent> <M-L> <Esc>:vsplit<CR>i

" Move Buffers
nmap <silent> <C-H> :bfirst!<CR>
nmap <silent> H :bprevious!<CR>
nmap <silent> L :bnext!<CR>
nmap <silent> <C-L> :blast!<CR>

" Disable Ex-Mode and map Q to close buffers
" TODO doesn't really work..
execute "source" $DOT_FILES_DIR . "/vim/custom/kill_buffer_not_split.vimrc"
nnoremap <silent> Q :call KillBufferNotSplit()<CR>

"}}}


"{{{ Load ENV_SPECIFIC things

if filereadable($DOT_FILES_DIR . "/." . $DOT_FILES_ENV . ".vimrc")
  execute "source" $DOT_FILES_DIR . "/." . $DOT_FILES_ENV . ".vimrc"
endif

"}}}


" TODO Ideas:
" - a 'verb' that behaves like `c` but basically searches for what was deleted
"   so you can `n.` your way to changing the entire file.
" - a surround and pre-pend type utility to turn `foo` into `x { foo }` or the
"   'do'/'end' variant
" - a `ub` motion like `t`, but one character before that:
"   `|let xyz = abc` -> `cub=` will change the `let xyz`, where as `ct=`
"   includes the ` `
" - a mapping for <C-A/X> that moves to the nearest number and changes it
" - gundo for undo tree
" - split this so it can be used as needed
