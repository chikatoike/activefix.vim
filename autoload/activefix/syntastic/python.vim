" this file is based on syntastic/syntax_checkers/python.vim
"============================================================================
"File:        python.vim
"Description: Syntax checking plugin for syntastic.vim
"
"Authors:     Martin Grenfell <martin.grenfell@gmail.com>
"             kstep <me@kstep.me>
"             Parantapa Bhattacharya <parantapa@gmail.com>
"
"
" For forcing the use of flake8, pyflakes, or pylint set
"
"   let g:syntastic_python_checker = 'pyflakes'
"
" in your .vimrc. Default is flake8.
"============================================================================


if !exists('g:syntastic_python_checker_args')
    let g:syntastic_python_checker_args = ''
endif

let s:supported_checkers = ["flake8", "pyflakes", "pylint"]
call activefix#syntastic#load_checker(s:supported_checkers, 'python')
