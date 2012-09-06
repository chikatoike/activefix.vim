" this file is based on syntastic/syntax_checkers/haml.vim
"============================================================================
"File:        haml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have the haml binary installed
if !executable("haml")
    finish
endif

function! activefix#syntastic#haml#config()
    let makeprg = "haml -c " . shellescape(activefix#syntastic#expand_target('haml', "%"))
    let errorformat = 'Haml error on line %l: %m,Syntax error on line %l: %m,%-G%.%#'
    return { 'makeprg': makeprg, 'errorformat': errorformat }
endfunction
