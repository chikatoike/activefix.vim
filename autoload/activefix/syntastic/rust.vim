" this file is based on syntastic/syntax_checkers/rust.vim
"============================================================================
"File:        rust.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Chad Jablonski <chad.jablonski at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have rustc installed
if !executable("rustc")
    finish
endif

function! activefix#syntastic#rust#config()
    let makeprg = 'rustc --parse-only '.shellescape(activefix#syntastic#expand_target('rust', '%'))

    let errorformat  = '%E%f:%l:%c: \\d%#:\\d%# %.%\{-}error:%.%\{-} %m,'   .
                     \ '%W%f:%l:%c: \\d%#:\\d%# %.%\{-}warning:%.%\{-} %m,' .
                     \ '%C%f:%l %m,' .
                     \ '%-Z%.%#'

    return { 'makeprg': makeprg, 'errorformat': errorformat }
endfunction


