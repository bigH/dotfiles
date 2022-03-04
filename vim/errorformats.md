**NOTE**: Eslint compact efm has been sourced from https://github.com/vim/vim/blob/master/runtime/compiler/eslint.vim and contributed by /u/-romainl-

Eslint --format compact
```vim
setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m,%-G%.%#
```

Eslint --format stylish
```vim
setlocal errorformat^=%-P%f,
		\%\\s%#%l:%c\ %#\ %trror\ \ %m,
		\%\\s%#%l:%c\ %#\ %tarning\ \ %m,
		\%-Q,
		\%-G%.%#,
```

Jest
```vim
setlocal errorformat^=%-G%[%^\ ]%.%#,
      \%-G%.%#Test\ suite\ failed\ to\ run,
      \%E%.%#SyntaxError:\ %f:\ %m\ (%l:%c),
      \%E%.%#●\ %m,
      \%Z%.%#at\ %.%#\ (%f:%l:%c),
      \%C%.%#,
      \%-G%.%#
```

Tsc
```vim
setlocal errorformat^=%E%f\ %#(%l\\,%c):\ %trror\ TS%n:\ %m,
		\%W%f\ %#(%l\\,%c):\ %tarning\ TS%n:\ %m,
```

