" this file is based on syntastic/syntax_checkers/html/w3.vim
"============================================================================
"File:        w3.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! activefix#syntastic#html#w3#config()
    let makeprg2="curl -s -F output=text -F \"uploaded_file=@".activefix#syntastic#expand_target('html/w3', '%:p').";type=text/html\" http://validator.w3.org/check \\| sed -n -e '/\<em\>Line\.\*/ \{ N; s/\\n//; N; s/\\n//; /msg/p; \}' -e ''/msg_warn/p'' -e ''/msg_info/p'' \\| sed -e 's/[ ]\\+/ /g' -e 's/\<[\^\>]\*\>//g' -e 's/\^[ ]//g'"
    let errorformat2='Line %l\, Column %c: %m'
    return { 'makeprg': makeprg2, 'errorformat': errorformat2 }

    let n = len(loclist) - 1
    let bufnum = bufnr("")
    while n >= 0
        let i = loclist[n]
        let i['bufnr'] = bufnum

        if i['lnum'] == 0
            let i['type'] = 'w'
        else
            let i['type'] = 'e'
        endif
        let n -= 1
    endwhile

    return loclist
endfunction
