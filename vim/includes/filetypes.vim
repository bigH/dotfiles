if exists('g:overriding_filetype_defaults')
  finish
endif
let g:overriding_filetype_defaults = 1

function s:SetupJSBindings()
  " go sort the list
  if IsPluginLoaded('kana/vim-textobj-indent')
    nmap <silent> <leader>gs vii:sort<CR>
    if IsPluginLoaded('AndrewRadev/splitjoin.vim')
      nmap <silent> <leader>si sjjvii:sort<CR>
    endif
  endif

  " go create a variable with . & " registers
  nnoremap <silent> <leader>gc oconst <C-R>. = <C-R>"
  nnoremap <silent> <leader>gl olet <C-R>. = <C-R>"
endfunction

" Defaults for certain files
augroup FiletypeSettings
  " Always use tabs in gitconfig
  au BufNewFile,BufRead gitconfig set filetype=gitconfig
  au FileType gitconfig setlocal noexpandtab

  " Gitignore filenames
  au BufNewFile,BufRead *gitignore* set filetype=gitignore

  " 4-space-y languages
  au FileType solidity setlocal tabstop=4 | setlocal shiftwidth=4
  au FileType go setlocal tabstop=4 | setlocal shiftwidth=4
  au FileType java setlocal tabstop=4 | setlocal shiftwidth=4

  " TypeScript and JavaScript `gf`
  au FileType typescriptreact setlocal suffixesadd=.ts,.tsx,.js,.jsx | call s:SetupJSBindings()
  au FileType typescript      setlocal suffixesadd=.ts,.tsx,.js,.jsx | call s:SetupJSBindings()
  au FileType javascript.jsx  setlocal suffixesadd=.ts,.tsx,.js,.jsx | call s:SetupJSBindings()
  au FileType jsx             setlocal suffixesadd=.ts,.tsx,.js,.jsx | call s:SetupJSBindings()

  " Always use wrapping in markdown
  au FileType markdown setlocal wrap

  " properly detect dockerfiles
  au BufNewFile,BufRead *.dockerfile set filetype=dockerfile
  au BufNewFile,BufRead Dockerfile* set filetype=dockerfile

  " Wrap long lines in quickfix windows
  au FileType qf setlocal wrap

  " Set cursorline in quickfix windows
  au FileType qf setlocal cursorline
augroup END


