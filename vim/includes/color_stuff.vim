if exists('g:color_stuff')
	finish
endif
let g:color_stuff = 1


"{{{ Color Scheme Toggle

" choosing dark default
let color_scheme_mode = 0 " 0 = dark, 1 = light
set background=dark

func! ColorSchemeLightDark()
	if g:color_scheme_mode == 0
		set background=light
		let g:color_scheme_mode = 1
	else
		set background=dark
		let g:color_scheme_mode = 0
	endif
	return
endfunc

nnoremap <silent> <F12> :call ColorSchemeLightDark()<CR>
inoremap <silent> <F12> <Esc>:call ColorSchemeLightDark()<CR>a

"}}}


"{{{ Colors

" Use correct vim colors
if !empty(globpath(&rtp, 'colors/gruvbox.vim'))
	colorscheme gruvbox
	let g:airline_theme='gruvbox'
endif

"}}}


