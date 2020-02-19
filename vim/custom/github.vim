if exists('g:custom_github')
  finish
endif

let g:custom_github = 1

function! s:GithubOpenFile()
  if (system('is-in-git-repo'))
    let base_url = system('git web')
  endif
endfunction

" nmap <silent> <leader>gh :<C-U> call <SID>
