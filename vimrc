"{{{ Includes

exec "source" $DOT_FILES_DIR . "/" . "vim/includes/core.vim"

exec "source" $DOT_FILES_DIR . "/" . "vim/custom/modal_jump.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/modal_paste.vim"

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
  let g:python2_host_prog = '/usr/local/bin/python2'
  let g:python3_host_prog = '/usr/local/bin/python3'
endif

"}}}


"{{{ Pasting Only Useful in Code

" Re-indent when pasting
nnoremap p mmp=`]`m
nnoremap P mmP=`]`m

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
" TODO doesn't really work.. - `bd` seems `==`
execute "source" $DOT_FILES_DIR . "/" . "vim/custom/kill_buffer_not_split.vim"
nnoremap <silent> Q :call KillBufferNotSplit()<CR>

"}}}


"{{{ Load ENV_SPECIFIC things

if filereadable($DOT_FILES_DIR . "/" . $DOT_FILES_ENV . "/after.vim")
  execute "source" $DOT_FILES_DIR . "/" . $DOT_FILES_ENV . "/after.vim"
endif

"}}}


" TODO Ideas:
