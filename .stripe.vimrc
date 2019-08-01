"{{{ Shell Utilities (when using Ctrl-V)

" IsFile
function! DeleteIfNotFile()
  let line_contents = getline(".")
  if !filereadable(line_contents)
    delete _
  endif
endfunction

" ShFilesFromStacktrace
function! ShFilesFromStacktrace()
  %s/^\s*from //g
  %s/.*\/pay-server\///g
  %s/\.rb\:.*/.rb/g
  g/^vendor/d
  g/^/call DeleteIfNotFile()
  sort u
endfunction

" command for ShFilesFromStacktrace
command! ShFilesFromStacktrace call ShFilesFromStacktrace()

"}}}
