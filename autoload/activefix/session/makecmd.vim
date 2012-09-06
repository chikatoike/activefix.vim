let s:save_cpo = &cpo
set cpo&vim

let s:session = activefix#module#session_base()

function! activefix#session#makecmd#new()
  return deepcopy(s:session)
endfunction

function! s:session.init(event, file)
  if a:event !=# '#BufWritePost'
    return 0
  endif

  let list = activefix#config#get_config(a:file, 0)
  if empty(list)
    return
  endif

  " TODO support config array
  let self.config = list[0]
  return 1
endfunction

function! s:session.run()
  let self.hooks = activefix#module#make_hooks(self)
  call self.invoke_hook('ready')

  if mode() ==# 'i'
    echoerr "makecmd can't execute in insert-mode"
    return
  endif

  let loclist = s:execute_makecmd(self.config,
        \ g:activefix_use_locationlist, 
        \ !g:activefix_enable_quickfix)

  " NOTE: makecmd don't call hook-point-output, hook-point-success, hook-point-failure

  let context = {'loclist': loclist}
  call self.invoke_hook('filter', context)

  if g:activefix_enable_quickfix
    call activefix#set_loclist(context.loclist, 'r')
  endif

  call self.invoke_hook('finish', {'loclist': loclist})
  call self.sweep()
  call self.invoke_hook('exit')

  if has_key(self, 'hooks')
    call activefix#module#sweep_list(self.hooks)
  endif
endfunction

" from syntastic source

let s:running_windows = has("win16") || has("win32")

if !s:running_windows
    let s:uname = system('uname')
endif

function! s:execute_makecmd(options, locationlist, restore)
  let old_makeprg = &makeprg
  let old_shellpipe = &shellpipe
  let old_errorformat = &errorformat

  if s:OSSupportsShellpipeHack()
    "this is a hack to stop the screen needing to be ':redraw'n when
    "when :lmake is run. Otherwise the screen flickers annoyingly
    let &shellpipe='&>'
    let &shell = '/bin/bash'
  endif

  if has_key(a:options, 'makeprg')
    let &makeprg = a:options['makeprg']
  endif

  if has_key(a:options, 'errorformat')
    let &errorformat = a:options['errorformat']
  endif

  let errors = []

  try
    if a:locationlist
      " NOTE: show error if error was occured (not silent!)
      execute 'silent lmake!' get(a:options, 'arg', '')
      let errors = getloclist(0)
      if a:restore
        " lolder occurs error if current is oldest
        silent! lolder
      endif
    else
      execute 'silent make!' get(a:options, 'arg', '')
      let errors = getqflist()
      if a:restore
        silent! colder
      endif
    endif
  finally
    let &makeprg = old_makeprg
    let &errorformat = old_errorformat
    let &shellpipe=old_shellpipe
  endtry

  if s:OSSupportsShellpipeHack()
    redraw!
  endif

"   if has_key(a:options, 'defaults')
"     call SyntasticAddToErrors(errors, a:options['defaults'])
"   endif
" 
"   " Add subtype info if present.
"   if has_key(a:options, 'subtype')
"     call SyntasticAddToErrors(errors, {'subtype': a:options['subtype']})
"   endif

  return errors
endfunction

"the script changes &shellpipe and &shell to stop the screen flicking when
"shelling out to syntax checkers. Not all OSs support the hacks though
function! s:OSSupportsShellpipeHack()
    if !exists("s:os_supports_shellpipe_hack")
        let s:os_supports_shellpipe_hack = !s:running_windows && (s:uname !~ "FreeBSD") && (s:uname !~ "OpenBSD")
    endif
    return s:os_supports_shellpipe_hack
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
