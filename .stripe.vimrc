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

let g:is_pay_server = 0
if fnamemodify(getcwd(), ':p') == $HOME.'/stripe/pay-server/'
  let g:is_pay_server = 1
end

"{{{ Pay Test support

" TODO test that this works
function! s:PayTest(additional_params)
  let pay_test_command = 'pay test ' . expand('%') . a:additional_params
  " TODO may have to add more here to ensure terminal ends
  execute 'vsplit | terminal ' . pay_test_command
endfunction

if g:is_pay_server == 1
  " TODO better mappings
  nnoremap <leader>ptf :call <SID>PayTest('')<CR>
  nnoremap <leader>ptvf :call <SID>PayTest('--show-output --show-full-stacktrace')<CR>
  nnoremap <leader>ptl :call <SID>PayTest('-l ' . line('.'))<CR>
  nnoremap <leader>ptvl :call <SID>PayTest('--show-output --show-full-stacktrace -l ' . line('.'))<CR>
end

"}}}


"{{{

if g:is_pay_server == 1
  noremap <silent> <leader>gh :silent! exe '!open "https://git.corp.stripe.com/stripe-internal/pay-server/blob/master/' . expand('%') . '"'<cr>
	noremap <silent> <leader>lg :silent! exe '!open "https://livegrep.corp.stripe.com/search/stripe?fold_case=auto&regex=false&context=true&q=' . expand("<cword>") . '"'<cr>
endif

"}}}


"{{{

if has('nvim')
  if g:is_pay_server == 1
    " let g:LanguageClient_serverCommands.ruby = ['pay', 'exec', 'scripts/bin/typecheck', '--lsp']
  endif

  let g:LanguageClient_diagnosticsDisplay = {
        \     1: {
        \         "name": "Error",
        \         "texthl": "ALEError",
        \         "signText": "✘",
        \         "signTexthl": "Error",
        \     },
        \     2: {
        \         "name": "Warning",
        \         "texthl": "ALEWarning",
        \         "signText": "▲",
        \         "signTexthl": "Todo",
        \     },
        \     3: {
        \         "name": "Information",
        \         "texthl": "ALEError",
        \         "signText": "✘",
        \         "signTexthl": "Error",
        \     },
        \     4: {
        \         "name": "Hint",
        \         "texthl": "ALEWarning",
        \         "signText": "➤",
        \         "signTexthl": "Todo",
        \     },
        \ }

  " augroup LanguageClient
  "   au!

  "   au filetype ruby nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
  "   au filetype ruby nnoremap <silent> <C-Space> :call LanguageClient#textDocument_contextMenu()<CR>
  "   au filetype ruby nnoremap <silent> <leader>t :call LanguageClient#textDocument_definition()<CR>
  "   au filetype ruby nnoremap <silent> <leader>r :call LanguageClient#textDocument_references()<CR> :lopen<CR>
  " augroup END
endif

"}}}
