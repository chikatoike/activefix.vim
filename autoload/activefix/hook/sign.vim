let s:save_cpo = &cpo
set cpo&vim

let s:hook = {
\   'config': {
\   },
\ }

function! s:hook.init(session)
  let self.config.enable = g:activefix_enable_signs
endfunction

function! s:hook.on_finish(session, context)
  call activefix#sign#set(a:context.loclist)
endfunction

function! activefix#hook#sign#new()
  return deepcopy(s:hook)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
