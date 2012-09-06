let s:save_cpo = &cpo
set cpo&vim

let s:hook = {
\   'config': {
\   },
\ }

function! s:hook.init(session)
  let self.config.enable = g:activefix_enable_highlight
endfunction

function! s:hook.on_finish(session, context)
  call activefix#highlight#set(a:context.loclist)
endfunction

function! activefix#hook#highlight#new()
  return deepcopy(s:hook)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
