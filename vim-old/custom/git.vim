if exists('g:custom_git')
  finish
endif

let g:custom_git = 1

" required for GetVisualLineRange
execute "source" $DOT_FILES_DIR . "/" . "vim/includes/get_visual_selection.vim"

function! s:SyscallSucceeded(command_string)
  call system(a:command_string)
  return v:shell_error == 0
endfunction

function! s:SyscallTrimmed(command_string)
  let output = system(a:command_string)
  return trim(l:output)
endfunction

function! s:LineDetails(is_visual)
  if a:is_visual
    let [l:start, l:end] = GetVisualLineRange()
    if l:start == l:end
      return 'L' . l:start
    else
      return 'L' . l:start . '-L' . l:end
    end
  else
    return 'L' . line('.')
  endif
endfunction

function! s:GithubOpen(path)
  if s:SyscallSucceeded('is-in-git-repo')
    let base = s:SyscallTrimmed('git web')
    call system('open "' . l:base . '/' . a:path . '"')
  endif
endfunction

function! s:GithubOpenBranch(is_visual)
  if s:SyscallSucceeded('is-in-git-repo')
    let line_details = s:LineDetails(a:is_visual)
    let branch = s:SyscallTrimmed('git branch-name')
    let path = expand('%')
    call s:GithubOpen('blob/' . l:branch . '/' . l:path . '#' . l:line_details)
  endif
endfunction

function! s:GithubOpenMergeBase(is_visual)
  if s:SyscallSucceeded('is-in-git-repo')
    let line_details = s:LineDetails(a:is_visual)
    let branch = s:SyscallTrimmed('git merge-base-branch')
    let path = expand('%')
    call s:GithubOpen('blob/' . l:branch . '/' . l:path . '#' . l:line_details)
  endif
endfunction

function! s:GithubOpenBlame(is_visual)
  if s:SyscallSucceeded('is-in-git-repo')
    let line_details = s:LineDetails(a:is_visual)
    let branch = s:SyscallTrimmed('git merge-base-branch')
    let path = expand('%')
    call s:GithubOpen('blame/' . l:branch . '/' . l:path . '#' . l:line_details)
  endif
endfunction

function! s:SaveAndGitAdd()
  write
  if s:SyscallSucceeded('is-in-git-repo')
    silent execute '!git add %'
  endif
endfunction

function! s:SaveAndGitAddAll()
  wall
  if s:SyscallSucceeded('is-in-git-repo')
    silent execute '!git add --all'
  endif
endfunction

function! s:DeleteAndGitRm()
  wall
  if s:SyscallSucceeded('is-in-git-repo')
    silent execute '!git rm %'
  endif
endfunction

nmap <silent> <leader>gh :<C-U>call <SID>GithubOpenBranch(0)<CR>
vmap <silent> <leader>gh :<C-U>call <SID>GithubOpenBranch(1)<CR>

nmap <silent> <leader>gm :<C-U>call <SID>GithubOpenMergeBase(0)<CR>
vmap <silent> <leader>gm :<C-U>call <SID>GithubOpenMergeBase(1)<CR>

nmap <silent> <leader>gb :<C-U>call <SID>GithubOpenBlame(0)<CR>
vmap <silent> <leader>gb :<C-U>call <SID>GithubOpenBlame(1)<CR>

nmap <silent> <leader>gaf :<C-U>call <SID>SaveAndGitAdd()<CR>
nmap <silent> <leader>gaa :<C-U>call <SID>SaveAndGitAddAll()<CR>

if IsPluginLoaded('airblade/vim-gitgutter')
  nmap <silent> <leader>gsp :<C-U>GitGutterPreviewHunk<CR>
  nmap <silent> <leader>gap :<C-U>GitGutterStageHunk<CR>
  nmap <silent> <leader>gcp :<C-U>GitGutterUndoHunk<CR>
endif

nmap <silent> <leader>grm :<C-U>call <SID>DeleteAndGitRm()<CR>:BD<CR>
