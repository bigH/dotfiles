" Source main `vim`

let g:app_plugin_set = 'scratch'
exec "source" $DOT_FILES_DIR . "/vim/includes/core.vim"

"{{{ Special `scratch` stuff

" AutoSave
augroup SetupLoader
  autocmd VimEnter * call AutoSaveToggle()
augroup END

" override nowrap - vertical splits
set wrap

"}}}
