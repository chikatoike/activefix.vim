" this file is based on syntastic/syntax_checkers/tex.vim
"============================================================================
"File:        tex.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have lacheck installed
if !executable("lacheck")
    finish
endif

function! activefix#syntastic#tex#config()
    let makeprg = 'lacheck '.shellescape(activefix#syntastic#expand_target('tex', '%'))
    let errorformat =  '%-G** %f:,%E"%f"\, line %l: %m'
    return { 'makeprg': makeprg, 'errorformat': errorformat }
endfunction
