if exists('g:custom_github')
  finish
endif

let g:custom_github = 1

function! SyscallSucceeded(command_string)
  call system(a:command_string)
  return v:shell_error == 0
endfunction

function! SyscallTrimmed(command_string)
  let output = system(a:command_string)
  return trim(l:output)
endfunction

function! GithubOpen(path)
  if SyscallSucceeded('is-in-git-repo')
    let base = SyscallTrimmed('git web')
    call system('open "' . l:base . '/' . a:path . '"')
  endif
endfunction

function! GithubOpenMergeBase()
  if SyscallSucceeded('is-in-git-repo')
    let branch = SyscallTrimmed('git merge-base-branch')
    let path = expand('%')
    call GithubOpen('blob/' . l:branch . '/' . l:path)
  endif
endfunction

function! GithubOpenBlame()
  if SyscallSucceeded('is-in-git-repo')
    let branch = SyscallTrimmed('git merge-base-branch')
    let path = expand('%')
    call GithubOpen('blame/' . l:branch . '/' . l:path)
  endif
endfunction

nmap <silent> <leader>gh :<C-U> call GithubOpenMergeBase()<CR>
nmap <silent> <leader>gb :<C-U> call GithubOpenBlame()<CR>
