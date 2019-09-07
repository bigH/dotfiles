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


"{{{ Pay Test support

" TODO test that this works
function! s:PayTest(additional_params)
  let pay_test_command = 'pay test ' . expand('%') . a:additional_params
  " TODO may have to add more here to ensure terminal ends
  execute 'vsplit | terminal ' . pay_test_command
endfunction

if fnamemodify(getcwd(), ':p') == $HOME.'/stripe/pay-server/'
  nnoremap <leader>ptf :call <SID>PayTest('')<CR>
  nnoremap <leader>ptvf :call <SID>PayTest('--show-output --show-full-stacktrace')<CR>
  nnoremap <leader>ptl :call <SID>PayTest('-l ' . line('.'))<CR>
  nnoremap <leader>ptvl :call <SID>PayTest('--show-output --show-full-stacktrace -l ' . line('.'))<CR>
end

"}}}


"{{{

" let g:LanguageClient_diagnosticsDisplay = {
"       \     1: {
"       \         "name": "Error",
"       \         "texthl": "ALEError",
"       \         "signText": "✘",
"       \         "signTexthl": "Error",
"       \     },
"       \     2: {
"       \         "name": "Warning",
"       \         "texthl": "ALEWarning",
"       \         "signText": "▲",
"       \         "signTexthl": "Todo",
"       \     },
"       \     3: {
"       \         "name": "Information",
"       \         "texthl": "ALEError",
"       \         "signText": "✘",
"       \         "signTexthl": "Error",
"       \     },
"       \     4: {
"       \         "name": "Hint",
"       \         "texthl": "ALEWarning",
"       \         "signText": "➤",
"       \         "signTexthl": "Todo",
"       \     },
"       \ }

"}}}
