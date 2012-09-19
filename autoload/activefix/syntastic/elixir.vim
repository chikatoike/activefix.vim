" this file is based on syntastic/syntax_checkers/elixir.vim
"============================================================================
"File:        elixir.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Richard Ramsden <rramsden at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if !executable('elixir')
  finish
endif

function! activefix#syntastic#elixir#config()
  let makeprg = 'elixir ' . shellescape(activefix#syntastic#expand_target('elixir', '%'))
  let errorformat = '** %*[^\ ] %f:%l: %m'

  return { 'makeprg': makeprg, 'errorformat': errorformat }

  if !empty(elixir_results)
    return elixir_results
  endif
endfunction
