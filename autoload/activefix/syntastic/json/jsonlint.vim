" this file is based on syntastic/syntax_checkers/json/jsonlint.vim
"============================================================================
"File:        jsonlint.vim
"Description: JSON syntax checker - using jsonlint
"Maintainer:  Miller Medeiros <contact at millermedeiros dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

function! activefix#syntastic#json#jsonlint#config()
    let makeprg = 'jsonlint ' . shellescape(activefix#syntastic#expand_target('json/jsonlint', "%")) . ' --compact'
    let errorformat = '%ELine %l:%c,%Z\\s%#Reason: %m,%C%.%#,%f: line %l\, col %c\, %m,%-G%.%#'
    return { 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'bufnr': bufnr('')} }
endfunction
