if exists('g:overriding_filetype_defaults')
  finish
endif
let g:overriding_filetype_defaults = 1

" Defaults for certain files
augroup FiletypeSettings
  " Always use tabs in gitconfig
  au FileType gitconfig setlocal noexpandtab

  " Always use tabs in gitconfig
  au FileType markdown setlocal wrap

  " Wrap long lines in quickfix windows
  au FileType qf setlocal wrap

  " Set cursorline in quickfix windows
  au FileType qf setlocal cursorline
augroup END


