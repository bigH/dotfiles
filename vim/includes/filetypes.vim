if exists('g:overriding_filetype_defaults')
  finish
endif
let g:overriding_filetype_defaults = 1

" Defaults for certain files
augroup FiletypeSettings
  " Always use tabs in gitconfig
  au BufNewFile,BufRead gitconfig set filetype=gitconfig
  au FileType gitconfig setlocal noexpandtab

  " Always use wrapping in markdown
  au FileType markdown setlocal wrap

  " properly detect dockerfiles
  au BufNewFile,BufRead *.dockerfile set filetype=dockerfile

  " Wrap long lines in quickfix windows
  au FileType qf setlocal wrap

  " Set cursorline in quickfix windows
  au FileType qf setlocal cursorline
augroup END


