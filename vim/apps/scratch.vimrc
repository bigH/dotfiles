" Source main `vimrc`

let g:app_plugin_set = 'scratch'
exec "source" $DOT_FILES_DIR . "/vim/includes/core.vimrc"

"{{{ Special `scratch` stuff

" AutoSave
augroup SetupLoader
  autocmd VimEnter * call AutoSaveToggle()
augroup END

" override nowrap - vertical splits
set wrap

"}}}
