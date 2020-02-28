"{{{ Includes

exec "source" $DOT_FILES_DIR . "/" . "vim/includes/core.vim"

exec "source" $DOT_FILES_DIR . "/" . "vim/custom/github.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/modal_jump.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/modal_paste.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/ctags.vim"

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


"{{{ Pasting Only Useful in Code (TODO consider a different solution)??

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
nmap <silent> <M-X> :only<CR>
imap <silent> <M-X> <Esc>:only<CR>

" Move between windows using <M-H/J/K/L> keys
nmap <silent> <M-h> :wincmd h<CR>
imap <silent> <M-h> <Esc>:wincmd h<CR>i
nmap <silent> <M-j> :wincmd j<CR>
imap <silent> <M-j> <Esc>:wincmd j<CR>i
nmap <silent> <M-k> :wincmd k<CR>
imap <silent> <M-k> <Esc>:wincmd k<CR>i
nmap <silent> <M-l> :wincmd l<CR>
imap <silent> <M-l> <Esc>:wincmd l<CR>i

" Split windows using <M-S-H/J/K/L> keys
nmap <silent> <M-H> :vsplit<CR>:wincmd h<CR>
imap <silent> <M-H> <Esc>:vsplit<CR>:wincmd h<CR>i
nmap <silent> <M-J> :split<CR>
imap <silent> <M-J> <Esc>:split<CR>i
nmap <silent> <M-K> :split<CR>:wincmd k<CR>
imap <silent> <M-K> <Esc>:split<CR>:wincmd k<CR>i
nmap <silent> <M-L> :vsplit<CR>
imap <silent> <M-L> <Esc>:vsplit<CR>i

" Move Buffers
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/buffer_nav.vim"

" Disable Ex-Mode and map Q to close buffers
nnoremap <silent> Q :bd<CR>

"}}}


"{{{ Load ENV_SPECIFIC things

if filereadable($DOT_FILES_DIR . "/" . $DOT_FILES_ENV . "/after.vim")
  execute "source" $DOT_FILES_DIR . "/" . $DOT_FILES_ENV . "/after.vim"
endif

"}}}

