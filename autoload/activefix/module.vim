let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('activefix').load('Data.List', 'System.File', 'System.Filepath')

augroup plugin-activefix-module
  autocmd!
  autocmd CursorHold,CursorHoldI * call activefix#module#_poll_handler(0)
  " autocmd CursorMoved,CursorMovedI * call activefix#module#_poll_handler(1)

  autocmd InsertLeave * call activefix#module#_deferred_handler()
  autocmd CmdwinLeave * call activefix#module#_deferred_handler()
  " autocmd WinEnter * call activefix#module#_deferred_handler()
augroup END

" debug {{{
function! activefix#module#scope()
  return s:
endfunction
" }}}

" factory
function! activefix#module#create_runner(config)
  return activefix#runner#{g:activefix_default_runner}#new()
endfunction

function! activefix#module#create_analyzer(config)
  let analyzer_type = has_key(a:config, 'regexp')
        \ ? 'regexp' : 'quickfix'
  return activefix#analyzer#{analyzer_type}#new()
endfunction


" module
function! activefix#module#load(kind)
  " let overwrite = a:0 && a:1
  let ret = []

  let pat = 'autoload/activefix/' . a:kind . '/*.vim'
  for name in map(split(globpath(&runtimepath, pat), "\n"),
        \               'fnamemodify(v:val, ":t:r")')
    try
      let module = activefix#{a:kind}#{name}#new()
      " let module.kind = a:kind
      " let module.name = name
      " call quickrun#module#register(module, overwrite)
      call add(ret, module)
    catch /:E\%(117\|716\):/
      echoerr 'activefix: module "' . name . '" cannot load.' v:exception
    endtry
  endfor

  return ret
endfunction

function! activefix#module#sweep_list(modules)
  for module in a:modules
    if has_key(module, 'sweep')
      call module.sweep()
    endif
  endfor
endfunction


" hook
function! activefix#module#make_hooks(session)
  let hooks = activefix#module#load('hook')
  for hook in hooks
    call hook.init(a:session)
  endfor
  call filter(hooks, 'get(v:val.config, "enable", 1)')
  return hooks
endfunction

function! activefix#module#invoke_hooks(session, hooks, point, ...)
  let context = a:0 ? a:1 : {}
  let func = 'on_' . a:point
  let pri = printf('activefix#module#_get_priority(v:val, %s)', string(a:point))
  for hook in s:V.Data.List.sort_by(a:hooks, pri)
    if has_key(hook, func) && s:V.is_funcref(hook[func])
      call call(hook[func], [a:session, context], hook)
    endif
  endfor
endfunction

function! activefix#module#_get_priority(hook, point)
  if has_key(a:hook, 'priority')
    return a:hook.priority(a:point) - 0
  else
    return 0
  endif
endfunction


" session
let s:session = {}

function! activefix#module#session_base()
  return deepcopy(s:session)
endfunction

function! s:session.invoke_hook(point, ...)
  return call('activefix#module#invoke_hooks', [self, self.hooks, a:point] + a:000)
endfunction

function! s:session.continue()
  let self._continue_key = activefix#save_session(self)
  return self._continue_key
endfunction

function! s:session.tempname(...)
  let name = a:0 ? a:1 : tempname()
  if !has_key(self, '_temp_names')
    let self._temp_names = []
  endif
  call add(self._temp_names, name)
  return name
endfunction

function! s:session.tempsweep()
  " Remove temporary files.
  if has_key(self, '_temp_names')
    for name in self._temp_names
      if filewritable(name)
        call delete(name)
      elseif isdirectory(name)
        call s:V.System.File.rmdir(name)
      endif
    endfor
  endif
endfunction

" NOTE: requires unified a:path
function! s:session.contains_file(path)
  return 0
endfunction

" function! s:session.make_module(kind, line)
"   echoerr 'activefix: not implemented: session.make_module'
" endfunction

function! s:session.output(data)
  " echoerr 'activefix: not implemented: session.output'
endfunction

function! s:session.finish(...)
  " echoerr 'activefix: not implemented: session.finish'
endfunction

function! s:session.sweep()
  " echoerr 'activefix: not implemented: session.sweep'
endfunction


" registrable
let s:registrable = {}

function! activefix#module#registrable_base()
  return deepcopy(s:registrable)
endfunction

function! s:registrable.sweep()
  call self.unregister()
endfunction

function! s:registrable_register(list, object)
  " if s:indexof(a:list, a:object) >= 0
  "   return
  " endif
  call add(a:list, a:object)
endfunction

function! s:registrable_unregister(list, object)
  call filter(a:list, 'v:val isnot# a:object')
  " let index = s:indexof(a:list, a:object)
  " if index < 0
  "   return
  " endif
  " call remove(a:list, index)
endfunction


" pollable
" NOTE: pollable_base don't change updatetime
let s:pollers = []
let s:pollable = activefix#module#registrable_base()

function! activefix#module#pollable_base()
  return deepcopy(s:pollable)
endfunction

function! s:pollable.register()
  call s:registrable_register(s:pollers, self)
endfunction

function! s:pollable.unregister()
  call s:registrable_unregister(s:pollers, self)
endfunction

function! s:pollable.on_poll()
endfunction

function! s:pollable.on_moved()
endfunction

function! activefix#module#_poll_handler(cursormoved)
  " it may changed list inside loop
  let list = copy(s:pollers)

  for p in s:pollers
    if s:indexof(list, p) >= 0
      if g:activefix_debug_exception
        if !a:cursormoved
          call p.on_poll()
        else
          call p.on_moved()
        endif
      else

        try
          if !a:cursormoved
            call p.on_poll()
          else
            call p.on_moved()
          endif
        catch
          " TODO sweep session on error occured
          call s:registrable_unregister(s:pollers, p)
          echoerr v:exception
        endtry

      endif
    endif
  endfor
endfunction

function! s:indexof(list, object)
  for i in range(len(a:list))
    if a:list[i] is# a:object
      return i
    endif
  endfor
  return -1
endfunction


" deferred
let s:defers = []
let s:deferred = activefix#module#registrable_base()

function! activefix#module#defferd_base()
  return deepcopy(s:deferred)
endfunction

function! s:deferred.register()
  call s:registrable_register(s:defers, self)
endfunction

function! s:deferred.unregister()
  call s:registrable_unregister(s:defers, self)
endfunction

function! s:deferred.on_deferrd()
endfunction

function! activefix#module#_deferred_handler()
  " it may changed list inside loop
  let list = copy(s:defers)

  for p in s:defers
    if s:indexof(list, p) >= 0
      if g:activefix_debug_exception
        call p.on_deferrd()
      else

        try
          call p.on_deferrd()
        catch
          " TODO sweep session on error occured
          call s:registrable_unregister(s:pollers, p)
          echoerr v:exception
        endtry

      endif
    endif
  endfor
endfunction

" trampoline {{{
let s:trampoline_dict = {}

function! activefix#module#continous_textunlock(dict, func)
  if mode() !=# 'i'
    call a:dict[a:func]()
  endif

  let s:trampoline_dict = a:dict

  augroup plugin-activefix-trampoline
    execute 'autocmd! CursorMovedI * call s:trampoline_callee('
          \ . string(a:func)  . ',' . string(getpos('.')) . ')'
  augroup END

  let down = search('.', 'nw') != line('.')

  if down
    call feedkeys("\<Down>", 'n')
  else
    call feedkeys("\<Right>", 'n')
  endif
endfunction

function! s:trampoline_callee(func, pos)
  autocmd! plugin-activefix-trampoline
  call setpos('.', a:pos)
  call s:trampoline_dict[a:func]()
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
