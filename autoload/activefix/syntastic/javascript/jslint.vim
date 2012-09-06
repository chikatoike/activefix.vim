" this file is based on syntastic/syntax_checkers/javascript/jslint.vim
"============================================================================
"File:        jslint.vim
"Description: Javascript syntax checker - using jslint
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"Tested with jslint 0.1.4.
"============================================================================
if !exists("g:syntastic_javascript_jslint_conf")
    let g:syntastic_javascript_jslint_conf = "--white --undef --nomen --regexp --plusplus --bitwise --newcap --sloppy --vars"
endif

function! activefix#syntastic#javascript#jslint#HighlightTerm(error)
    let unexpected = matchstr(a:error['text'], 'Expected.*and instead saw \'\zs.*\ze\'')
    if len(unexpected) < 1 | return '' | end
    return '\V'.split(unexpected, "'")[1]
endfunction

function! activefix#syntastic#javascript#jslint#config()
    let makeprg = "jslint " . g:syntastic_javascript_jslint_conf . " " . shellescape(activefix#syntastic#expand_target('javascript/jslint', '%'))
    let errorformat='%E %##%n %m,%-Z%.%#Line %l\, Pos %c,%-G%.%#'
    return { 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'bufnr': bufnr("")} }
endfunction

