let s:save_cpo = &cpo
set cpo&vim

let s:hook = {
\   'config': {
\   },
\ }

function! s:hook.init(session)
  if g:activefix_output_verbose
    let self.config.condition = []
  else
    let self.config.condition = ['v:val.valid']
  endif
endfunction

function! s:hook.on_filter(session, context)
  for cond in self.config.condition
    call filter(a:context.loclist, cond)
  endfor
endfunction

function! activefix#hook#filter#new()
  return deepcopy(s:hook)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
