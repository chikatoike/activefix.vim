" this file is based on syntastic/syntax_checkers/python/pyflakes.vim
"============================================================================
"File:        pyflakes.vim
"Description: Syntax checking plugin for syntastic.vim
"Authors:     Martin Grenfell <martin.grenfell@gmail.com>
"             kstep <me@kstep.me>
"             Parantapa Bhattacharya <parantapa@gmail.com>
"
"============================================================================
function! activefix#syntastic#python#pyflakes#GetHighlightRegex(i)
    if match(a:i['text'], 'is assigned to but never used') > -1
                \ || match(a:i['text'], 'imported but unused') > -1
                \ || match(a:i['text'], 'undefined name') > -1
                \ || match(a:i['text'], 'redefinition of') > -1
                \ || match(a:i['text'], 'referenced before assignment') > -1
                \ || match(a:i['text'], 'duplicate argument') > -1
                \ || match(a:i['text'], 'after other statements') > -1
                \ || match(a:i['text'], 'shadowed by loop variable') > -1

        let term = split(a:i['text'], "'", 1)[1]
        return '\V\<'.term.'\>'
    endif
    return ''
endfunction

function! activefix#syntastic#python#pyflakes#config()
    let makeprg = 'pyflakes '.g:syntastic_python_checker_args.' '.shellescape(activefix#syntastic#expand_target('python/pyflakes', '%'))
    let errorformat = '%E%f:%l: could not compile,%-Z%p^,%E%f:%l:%c: %m,%E%f:%l: %m,%-G%.%#'

    return { 'makeprg': makeprg,
                               \ 'errorformat': errorformat,
                               \ 'defaults': {'text': "Syntax error"} }

    return errors
endfunction
