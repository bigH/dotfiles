"{{{ Includes

exec "source" $DOT_FILES_DIR . "/" . "vim/includes/core.vim"

exec "source" $DOT_FILES_DIR . "/" . "vim/custom/git.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/modal_jump.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/modal_paste.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/ctags.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/buffer_nav.vim"
exec "source" $DOT_FILES_DIR . "/" . "vim/custom/enlarge_view.vim"

"}}}

"{{{ AutoCommands

" Reload edited files.
augroup ReloadGitGutter
  autocmd FocusGained * GitGutterAll
  autocmd BufEnter * GitGutterAll
augroup end

" Remove any trailing whitespace that is in the file
autocmd BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

"}}}


"{{{ Needed for UltiSnips

if IsPluginLoaded('SirVer/UltiSnips')
  " Setup Python
  let g:python2_host_prog = '/usr/local/bin/python2'
  let g:python3_host_prog = '/usr/local/bin/python3'
endif

"}}}


"{{{ Pasting Only Useful in Code (TODO consider a different solution)??

nnoremap <leader>p p
nnoremap <leader>P P

vnoremap <leader>p p
vnoremap <leader>P P

"}}}


"{{{ Load DOT_FILES_ENV things

if filereadable($DOT_FILES_DIR . "/" . $DOT_FILES_ENV . "/after.vim")
  execute "source" $DOT_FILES_DIR . "/" . $DOT_FILES_ENV . "/after.vim"
endif

"}}}


"{{{ Turn on project-specific vimrc loading

if filereadable($PWD . "/.vimrc")
  execute "source" $PWD . "/.vimrc"
endif

"}}}

