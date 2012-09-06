" this file is based on syntastic/syntax_checkers/sass.vim
"============================================================================
"File:        sass.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have the sass binary installed
if !executable("sass")
    finish
endif

"use compass imports if available
let s:imports = ""
if executable("compass")
    let s:imports = "--compass"
endif

function! activefix#syntastic#sass#config()
    let makeprg='sass --no-cache '.s:imports.' --check '.shellescape(activefix#syntastic#expand_target('sass', '%'))
    let errorformat = '%ESyntax %trror:%m,%C        on line %l of %f,%Z%.%#'
    let errorformat .= ',%Wwarning on line %l:,%Z%m,Syntax %trror on line %l: %m'
    return { 'makeprg': makeprg, 'errorformat': errorformat }

    return loclist
endfunction
