" this file is based on syntastic/syntax_checkers/xslt.vim
"============================================================================
"File:        xslt.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sebastian Kusnier <sebastian at kusnier dot net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have tidy or grep installed
if !executable("xmllint")
    finish
endif

function! activefix#syntastic#xslt#config()

    let makeprg="xmllint --xinclude --noout --postvalid " . shellescape(activefix#syntastic#expand_target('xslt', "%:p"))
    let errorformat='%E%f:%l:\ error\ :\ %m,
        \%-G%f:%l:\ validity\ error\ :\ Validation\ failed:\ no\ DTD\ found\ %m,
        \%W%f:%l:\ warning\ :\ %m,
        \%W%f:%l:\ validity\ warning\ :\ %m,
        \%E%f:%l:\ validity\ error\ :\ %m,
        \%E%f:%l:\ parser\ error\ :\ %m,
        \%E%f:%l:\ namespace\ error\ :\ %m,
        \%E%f:%l:\ %m,
        \%-Z%p^,
        \%-G%.%#'
    return { 'makeprg': makeprg, 'errorformat': errorformat }

    return loclist
endfunction
