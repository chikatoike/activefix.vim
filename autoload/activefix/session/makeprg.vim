let s:save_cpo = &cpo
set cpo&vim

let s:session = activefix#module#session_base()

function! activefix#session#makeprg#new()
  return deepcopy(s:session)
endfunction

function! s:session.init(event, file)
  " TODO
  if a:event !=# '@update'
    if exists('b:activefix_status')
          \ && b:activefix_status.changedtick == b:changedtick
      return 0
    endif
  endif

  let b:activefix_status = {}
  let b:activefix_status.event = a:event
  let b:activefix_status.changedtick = b:changedtick

  let list = activefix#config#get_config(a:file, 1)
  if empty(list)
    return 0
  endif

  " TODO support config array
  let self.config = list[0]
  return 1
endfunction

function! s:session.run()
  let self._running = 1
  let self.runner = activefix#module#create_runner(self.config)
  let self.analyzer = activefix#module#create_analyzer(self.config)
  let self.hooks = activefix#module#make_hooks(self)

  let self._depends = copy(self.config.target)

  if &modified
        \ && count(keys(self.config.tempfile), activefix#unify_path(expand('%:p'))) == 0
        \ && count(self.config.target, activefix#unify_path(expand('%:p'))) >= 1
    if !g:activefix_allow_auto_save
      return
    endif

    " save current buffer
    update
    set modified
  endif

  " copy file to temporary file
  for [src, dest] in items(self.config.tempfile)
    call self.tempname(dest)
    call activefix#writefile(src, dest)
  endfor

  call self.invoke_hook('ready')

  let context = {'commands': [self.config.makeprg]}
  call self.invoke_hook('command', context)
  let commands = context.commands

  let exit_code = 1

  let env = activefix#process#set_env(self.config)
  try
    call self.analyzer.start(self)
    let exit_code = self.runner.run(commands, '', self)
  finally
    call activefix#process#restore_env(env)

    if !has_key(self, '_continue_key')
      call self.finish(exit_code)
    endif
  endtry
endfunction

function! s:session.output(data)
  let context = {'data': a:data}
  call self.invoke_hook('output', context)
  if context.data !=# ''
    call self.analyzer.output(context.data, self)
  endif
endfunction

function! s:session.finish(...)
  if !has_key(self, 'exit_code')
    let self.exit_code = a:0 ? a:1 : 0
    if self.exit_code == 0
      call self.invoke_hook('success')
    else
      call self.invoke_hook('failure', {'exit_code': self.exit_code})
    endif

    let loclist = self.analyzer.finish(self)
    let loclist = activefix#filter#convert_path(loclist,
          \ activefix#reverse_dict(self.config.tempfile))
    let context = {'loclist': loclist}
    call self.invoke_hook('filter', context)

    if g:activefix_enable_quickfix
      " TODO locactionlistが表示できない状態の時は遅延する
      call activefix#set_loclist(context.loclist, 'r') " NOTE: overwrite current locactionlist
    endif

    call self.invoke_hook('finish', {'loclist': loclist})
    call self.sweep()
    call self.invoke_hook('exit')
  endif

  " TODO start next session if exists
endfunction

" Sweep the session.
function! s:session.sweep()
  call self.tempsweep()

  " Sweep the execution of vimproc.
  if has_key(self, '_vimproc')
    try
      call self._vimproc.kill(15)
      call self._vimproc.waitpid()
    catch
    endtry
    call remove(self, '_vimproc')
  endif

  if has_key(self, '_continue_key')
    call activefix#remove_session(self._continue_key)
    call remove(self, '_continue_key')
  endif

  if has_key(self, 'runner')
    call self.runner.sweep()
  endif

  if has_key(self, 'analyzer')
    if has_key(self.analyzer, 'sweep')
      call self.analyzer.sweep()
    endif
  endif

  if has_key(self, 'hooks')
    call activefix#module#sweep_list(self.hooks)
  endif

  if has_key(self, '_running')
    call remove(self, '_running')
  endif
endfunction

function! s:session.contains_file(path)
  return index(self._depends, a:path) >= 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
