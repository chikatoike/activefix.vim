" this file is based on syntastic/syntax_checkers/eruby.vim
"============================================================================
"File:        eruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have ruby or cat installed
if !executable("ruby") || !executable("cat")
    finish
endif

function! activefix#syntastic#eruby#config()
    if has('win32')
        let makeprg='sed "s/<\%=/<\%/g" '. shellescape(activefix#syntastic#expand_target('eruby', "%")) . ' \| ruby -e "require \"erb\"; puts ERB.new(ARGF.read, nil, \"-\").src" \| ruby -c'
    else
        let makeprg='sed "s/<\%=/<\%/g" '. shellescape(activefix#syntastic#expand_target('eruby', "%")) . ' \| RUBYOPT= ruby -e "require \"erb\"; puts ERB.new(ARGF.read, nil, \"-\").src" \| RUBYOPT= ruby -c'
    endif

    let errorformat='%-GSyntax OK,%E-:%l: syntax error\, %m,%Z%p^,%W-:%l: warning: %m,%Z%p^,%-C%.%#'
    return { 'makeprg': makeprg,
                         \ 'errorformat': errorformat,
                         \ 'defaults': {'bufnr': bufnr("")} }

endfunction
