" this file is based on syntastic/syntax_checkers/tcl.vim
"============================================================================
"File: tcl.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer: Eric Thomas <eric.l.m.thomas at gmail dot com>
"License: This program is free software. It comes without any warranty,
" to the extent permitted by applicable law. You can redistribute
" it and/or modify it under the terms of the Do What The Fuck You
" Want To Public License, Version 2, as published by Sam Hocevar.
" See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================


"bail if the user doesnt have tclsh installed
if !executable("tclsh")
    finish
endif

function! activefix#syntastic#tcl#config()
    let makeprg = 'tclsh '.shellescape(activefix#syntastic#expand_target('tcl', '%'))
    let errorformat = '%f:%l:%m'

    return { 'makeprg': makeprg, 'errorformat': errorformat }
endfunction
