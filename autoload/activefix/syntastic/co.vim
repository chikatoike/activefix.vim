" this file is based on syntastic/syntax_checkers/co.vim
"============================================================================
"File:        co.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Andrew Kelley <superjoe30@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have coco installed
if !executable("coco")
    finish
endif

function! activefix#syntastic#co#config()
    let makeprg = 'coco -c -o /tmp '.shellescape(activefix#syntastic#expand_target('co', '%'))
    let errorformat = '%EFailed at: %f,%ZSyntax%trror: %m on line %l,%EFailed at: %f,%Z%trror: Parse error on line %l: %m'

    return { 'makeprg': makeprg, 'errorformat': errorformat }
endfunction
