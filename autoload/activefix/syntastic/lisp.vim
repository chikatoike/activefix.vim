" this file is based on syntastic/syntax_checkers/lisp.vim
"============================================================================
"File:        lisp.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Karl Yngve Lervåg <karl.yngve@lervag.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================


" Bail if the user doesnt have clisp installed
if !executable("clisp")
  finish
endif

function! activefix#syntastic#lisp#config()
  let makeprg  = 'clisp -c ' . shellescape(activefix#syntastic#expand_target('lisp', '%'))
  let makeprg .= ' -o /tmp/clisp-vim-compiled-file'
  let efm  = '%-G;%.%#,'
  let efm .= '%W%>WARNING:%.%#line %l : %m,%C  %#%m,'
  let efm .= '%E%>The following functions were %m,%Z %m,'
  let efm .= '%-G%.%#'
  return { 'makeprg': makeprg, 'errorformat': efm }
endfunction
