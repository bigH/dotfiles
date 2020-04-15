if exists('g:overriding_filetype_defaults')
  finish
endif
let g:overriding_filetype_defaults = 1

" Defaults for certain files
augroup FiletypeSettings
  " Always use tabs in gitconfig
  au BufNewFile,BufRead gitconfig set filetype=gitconfig
  au FileType gitconfig setlocal noexpandtab

  " TypeScript and JavaScript `gf`
  au FileType typescriptreact setlocal suffixesadd=.ts,.tsx,.js,.jsx
  au FileType typescript      setlocal suffixesadd=.ts,.tsx,.js,.jsx
  au FileType javascript.jsx  setlocal suffixesadd=.ts,.tsx,.js,.jsx
  au FileType jsx             setlocal suffixesadd=.ts,.tsx,.js,.jsx

  " Always use wrapping in markdown
  au FileType markdown setlocal wrap

  " properly detect dockerfiles
  au BufNewFile,BufRead *.dockerfile set filetype=dockerfile
  au BufNewFile,BufRead Dockerfile.* set filetype=dockerfile

  " Wrap long lines in quickfix windows
  au FileType qf setlocal wrap

  " Set cursorline in quickfix windows
  au FileType qf setlocal cursorline
augroup END


