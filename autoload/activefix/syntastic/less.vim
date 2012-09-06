" this file is based on syntastic/syntax_checkers/less.vim
"============================================================================
"File:        less.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Julien Blanchard <julien at sideburns dot eu>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have the lessc binary installed
if !executable("lessc")
    finish
endif

if !exists("g:syntastic_less_options")
    let g:syntastic_less_options = "--no-color"
endif

function! activefix#syntastic#less#config()
    let makeprg = 'lessc '. g:syntastic_less_options .' '.  shellescape(activefix#syntastic#expand_target('less', '%')) . ' /dev/null'

    "lessc >= 1.2
    let errorformat = '%m in %f:%l:%c'
    "lessc < 1.2
    let errorformat .= ', Syntax %trror on line %l in %f,Syntax %trror on line %l,! Syntax %trror: on line %l: %m,%-G%.%#'

    return { 'makeprg': makeprg,
                         \ 'errorformat': errorformat,
                         \ 'defaults': {'bufnr': bufnr(""), 'text': "Syntax error"} }
endfunction

