" this file is based on syntastic/syntax_checkers/cuda.vim
"============================================================================
"File:        cuda.vim
"Description: Syntax checking plugin for syntastic.vim
"
"Author:      Hannes Schulz <schulz at ais dot uni-bonn dot de>
"
"============================================================================

" in order to also check header files add this to your .vimrc:
" (this creates an empty .syntastic_dummy.cu file in your source directory)
"
"   let g:syntastic_cuda_check_header = 1

" By default, nvcc and thus syntastic, defaults to the most basic architecture.
" This can produce false errors if the developer intends to compile for newer
" hardware and use newer features, eg. double precision numbers. To pass a
" specific target arch to nvcc, e.g. add the following to your .vimrc:
"
"   let g:syntastic_cuda_arch = "sm_20"


if !executable('nvcc')
    finish
endif

function! activefix#syntastic#cuda#config()
    if exists('g:syntastic_cuda_arch')
        let arch_flag = '-arch='.g:syntastic_cuda_arch
    else
        let arch_flag = ''
    endif
    let makeprg = 'nvcc '.arch_flag.' --cuda -O0 -I . -Xcompiler -fsyntax-only '.shellescape(activefix#syntastic#expand_target('cuda', '%')).' -o /dev/null'
    "let errorformat =  '%-G%f:%s:,%f:%l:%c: %m,%f:%l: %m'
    let errorformat =  '%*[^"]"%f"%*\D%l: %m,"%f"%*\D%l: %m,%-G%f:%l: (Each undeclared identifier is reported only once,%-G%f:%l: for each function it appears in.),%f:%l:%c:%m,%f(%l):%m,%f:%l:%m,"%f"\, line %l%*\D%c%*[^ ] %m,%D%*\a[%*\d]: Entering directory `%f'',%X%*\a[%*\d]: Leaving directory `%f'',%D%*\a: Entering directory `%f'',%X%*\a: Leaving directory `%f'',%DMaking %*\a in %f,%f|%l| %m'

    if activefix#syntastic#expand_target('cuda', '%') =~? '\%(.h\|.hpp\|.cuh\)$'
        if exists('g:syntastic_cuda_check_header')
            let makeprg = 'echo > .syntastic_dummy.cu ; nvcc '.arch_flag.' --cuda -O0 -I . .syntastic_dummy.cu -Xcompiler -fsyntax-only -include '.shellescape(activefix#syntastic#expand_target('cuda', '%')).' -o /dev/null'
        else
            return []
        endif
    endif

    return { 'makeprg': makeprg, 'errorformat': errorformat }
endfunction
