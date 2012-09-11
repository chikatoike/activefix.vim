let s:save_cpo = &cpo
set cpo&vim

let g:activefix_debug_hook =
      \ get(g:, 'activefix_debug_hook', 0)

let s:hook = {
\   'config': {
\   },
\ }

function! s:hook.init(session)
  let self.config.enable = g:activefix_debug_hook
endfunction

" function! s:hook.on_hook_loaded(session, context)
" endfunction
" 
" function! s:hook.on_normalized(session, context)
" endfunction
" 
" function! s:hook.on_module_loaded(session, context)
" endfunction

function! s:hook.on_ready(session, context)
  call s:addlog('------------------------------------------------------------------------')
  call s:trace('ready', a:context, a:session.config, a:session.hooks)
  " call s:trace('ready', a:context, a:session.config, map(copy(a:session.hooks), 'v:val.config'))
endfunction

function! s:hook.on_command(session, context)
  call s:trace('command', a:context)
endfunction

function! s:hook.on_output(session, context)
  call s:trace('output', a:context)
endfunction

function! s:hook.on_success(session, context)
  call s:trace('success', a:context)
  let self._tick = reltime()
endfunction

function! s:hook.on_failure(session, context)
  call s:trace('failure', a:context)
  let self._tick = reltime()
endfunction

function! s:hook.on_filter(session, context)
  call s:trace('filter', a:context)
endfunction

function! s:hook.on_finish(session, context)
  call s:trace('finish', {'error count': len(a:context.loclist)})
endfunction

function! s:hook.on_exit(session, context)
  let elapsed = string(reltimestr(reltime(self._tick)))
  call s:trace('exit', a:context, {'finishing time': elapsed})
endfunction

let s:logpath = expand('<sfile>:p:h') . '/_afdebug.log'

function! s:trace(point, ...)
  let str = printf('%s: hook-%s: %s', strftime('%c'), a:point, string(a:000))
  call s:addlog(str)
  " call s:addlog('ls: ' . expand('*.c'))
endfunction

function! s:addlog(str)
  silent! let list = readfile(s:logpath)
  call writefile(list + [a:str], s:logpath)
endfunction

function! activefix#hook#_afdebug#new()
  return deepcopy(s:hook)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
