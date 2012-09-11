let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('activefix')

" option: features
let g:activefix_enable_quickfix =
      \ get(g:, 'activefix_enable_quickfix', 1)

let g:activefix_enable_highlight =
      \ get(g:, 'activefix_enable_highlight', 1)

let g:activefix_enable_echodoc =
      \ get(g:, 'activefix_enable_echodoc', 1)

let g:activefix_enable_signs =
      \ !has('signs') ? 0 :
      \ get(g:, 'activefix_enable_signs', 0)

let g:activefix_enable_balloons =
      \ !has('balloon_eval') ? 0 :
      \ get(g:, 'activefix_enable_balloons', 1)

" let g:activefix_enable_unite =
"       \ globpath(&runtimepath, 'plugin/unite.vim') ==# '' ? 0 :
"       \ get(g:, 'activefix_enable_unite', 0)

let g:activefix_use_compiler_plugin =
      \ get(g:, 'activefix_use_compiler_plugin', 0)

" option: behavior
let g:activefix_allow_auto_save =
      \ get(g:, 'activefix_allow_auto_save', 0)

let g:activefix_quickfix_auto_open =
      \ get(g:, 'activefix_quickfix_auto_open', 1)

let g:activefix_quickfix_split =
      \ get(g:, 'activefix_quickfix_split', '')

let g:activefix_quickfix_height =
      \ get(g:, 'activefix_quickfix_height', 10)

let g:activefix_use_locationlist =
      \ get(g:, 'activefix_use_locationlist', 1)

" let g:activefix_unite_buffer_name =
"       \ get(g:, 'activefix_unite_buffer_name', 'default')

" option
let g:activefix_default_method =
      \ get(g:, 'g:activefix_default_method', 'makeprg')

let g:activefix_default_runner =
      \ get(g:, 'g:activefix_default_runner', 'vimproc')

if !s:V.has_vimproc()
  let g:activefix_default_method = 'makecmd'
endif

" option: signs
if !exists("g:activefix_signs_error_symbol")
  let g:activefix_signs_error_symbol = '>>'
endif

if !exists("g:activefix_signs_warning_symbol")
  let g:activefix_signs_warning_symbol = '>>'
endif

" option
let g:activefix_output_verbose =
      \ get(g:, 'activefix_output_verbose', 0)

let g:activefix_enable_on_readonly =
      \ get(g:, 'activefix_enable_on_readonly', 0)

" let g:activefix_encoding =
"       \ get(g:, 'activefix_encoding', '')
" 
" let g:activefix_updatetime_start_delay =
"       \ get(g:, 'activefix_updatetime_start_delay', 0)

let g:activefix_updatetime_running =
      \ get(g:, 'activefix_updatetime_running', 0)

let g:activefix_updatetime_minimun =
      \ get(g:, 'activefix_updatetime_minimun', 500)
 
let g:activefix_activation_event =
      \ get(g:, 'activefix_activation_event', {})
" call extend(g:activefix_activation_event, {
"       \ 'read': 1,
"       \ 'write': 1,
"       \ 'hold': 1,
"       \ 'hold_insert': 1,
"       \ }, 'keep')

let g:activefix_filetype_pattern =
      \ get(g:, 'activefix_filetype_pattern', {})
call extend(g:activefix_filetype_pattern, {
      \ 'java': '.*\.java$',
      \ }, 'keep')

" option: config
if !exists('g:activefix_config')
  let g:activefix_config = {}
endif


function! activefix#_on_bufreadpost()
  call s:event_proc('#BufReadPost')
endfunction

function! activefix#_on_bufwritepost()
  call s:event_proc('#BufWritePost')
endfunction

function! activefix#_on_bufdelete()
  call activefix#kill_file_session(expand('%:p'))
endfunction

function! activefix#_on_cursorhold(insert)
  if &updatetime < g:activefix_updatetime_minimun
    " Ignore CursorHold event
    return
  endif

  let path = expand('%:p')
  if !activefix#is_need_updating(path)
    return
  endif

  call s:event_proc(a:insert ? '#CursorHoldI' : '#CursorHold')
endfunction

function! activefix#update()
  call s:event_proc('@update')
endfunction

function! activefix#stop()
  call activefix#sweep_sessions()
endfunction

let s:status_global_enable = 1
let s:status_filetype = {}

function! activefix#set_enable(enable)
  let s:status_global_enable = a:enable
endfunction

function! activefix#set_enable_filetype(enable)
  let s:status_global_enable = a:enable

  if !a:enable
    " TODO use global hook
    call activefix#highlight#clear()
  endif
endfunction

function! activefix#set_enable_filetype(enable, filetype)
  if !has_key(s:status_filetype, a:filetype)
    let s:status_filetype[a:filetype] = {}
  endif
  let s:status_filetype[a:filetype].enable = a:enable
endfunction

function! activefix#set_enable_buffer(enable, bufnr)
  call setbufvar(a:bufnr, 'activefix_enable', a:enable)
endfunction

function! activefix#is_file_enable(file)
  let filetype = activefix#get_filetype(a:file)

  if filetype ==# ''
    return 0
  endif

  if filetype ==# 'vim'
    " filetype vim is not supported
    return 0
  endif

  if !g:activefix_enable_on_readonly && activefix#is_readonly(a:file)
    return 0
  endif

  if getbufvar(a:file, '&buftype') !=# '' || !filereadable(a:file)
    return 0
  endif

  if !s:status_global_enable
        \ || getbufvar(a:file, 'activefix_enable') is 0
    return 0
  endif

  if exists('s:status_filetype[filetype].enable')
        \ && !s:status_filetype[filetype].enable
    return 0
  endif

  return 1
endfunction

function! activefix#make(arg)
  call s:start_session('make', 'makecmd')
endfunction

function! s:event_proc(event)
  call s:start_session(a:event, g:activefix_default_method)
endfunction

function! s:start_session(event, method)
  if a:event ==# '#CursorHold' && !get(g:activefix_activation_event, 'hold', 1)
    return
  elseif a:event ==# '#CursorHoldI' && !get(g:activefix_activation_event, 'hold_insert', 1)
    return
  endif

  let file = expand('%:p')
  if !activefix#is_file_enable(file)
    return
  endif

  let session = activefix#session#{a:method}#new()
  if !session.init(a:event, file)
    " call session.sweep()
    return
  endif

  call activefix#kill_file_session(file)

  try
    call session.run()
  catch /^vimproc.*/
    call s:session_error(file, v:exception)
  catch /^activefix:.*/
    call s:session_error(file, v:exception)
  endtry
endfunction

function! s:session_error(file, error)
  let filetype = activefix#get_filetype(a:file)
  call activefix#set_enable_filetype(0, filetype)
  let message = printf('activefix: Error occured. activefix for %s is disabled.', filetype)
  " call s:echo_error(join([a:error, message], "\n"))
  call s:echo_error(a:error)
  call s:echo_error(message)
endfunction

function! activefix#print_error(string)
  echohl Error | echomsg 'activefix:' a:string | echohl None
endfunction

function! s:echo_error(string)
  echohl Error | echomsg a:string | echohl None
endfunction

" quickfix
function! activefix#set_loclist(loclist, ...)
  let action = get(a:000, 0, '')
  " NOTE: can't use winnr as window id because winnr is not fixed value
  " use windows count instead
  let wins = winnr('$')

  " NOTE: if quickfix window already opened, don't change current window size.
  if g:activefix_use_locationlist
    call setloclist(0, a:loclist, action)
    if g:activefix_quickfix_auto_open
      execute g:activefix_quickfix_split 'lwindow' g:activefix_quickfix_height
    endif
  else
    call setqflist(a:loclist, action)
    if g:activefix_quickfix_auto_open
      execute g:activefix_quickfix_split 'cwindow' g:activefix_quickfix_height
    endif
  endif

  if wins < winnr('$')
    " if windows count was increased then quickfix window opened

    " workaround for QFixHowm/QFixGrep
    if exists('#QFix#BufWinEnter')
      doautocmd QFix BufWinEnter
    endif

    " back to previous window
    wincmd p
  endif
endfunction

function! activefix#writefile(srcpath, destpath)
  if bufloaded(a:srcpath)
    let list = getbufline(a:srcpath, 1, '$')
    " TODO
    " if getbufvar(a:srcpath, '&fileformat') ==# 'dos'
    "   call map(list, 'v:val . "\\r"')
    " endif
    call writefile(list, a:destpath)

  else
    " NOTE: it doesn't care eol
    call writefile(readfile(a:srcpath), a:destpath)
  endif
endfunction

" from quickrun
let s:sessions = {}  " Store for sessions.

function! activefix#create_unique_key()
  return has('reltime') ? reltimestr(reltime()) : string(localtime())
endfunction

function! activefix#save_session(session)
    let key = has('reltime') ? reltimestr(reltime()) : string(localtime())
  let s:sessions[key] = a:session
  return key
endfunction

" Call a function of a session by key.
function! activefix#session(key, ...)
  let session = get(s:sessions, a:key, {})
  if a:0 && !empty(session)
    return call(session[a:1], a:000[1 :], session)
  endif
  return session
endfunction

function! s:dispose_session(key)
  if has_key(s:sessions, a:key)
    let session = remove(s:sessions, a:key)
    call session.sweep()
  endif
endfunction

function! activefix#sweep_sessions()
  call map(keys(s:sessions), 's:dispose_session(v:val)')
endfunction

function! activefix#remove_session(key)
  if has_key(s:sessions, a:key)
    call remove(s:sessions, a:key)
  endif
endfunction

" NOTE: running sessions is only saved sesions.
function! activefix#is_running()
  return len(s:sessions) > 0
endfunction

function! activefix#is_running_buffer(path)
  let path = activefix#unify_path(a:path)
  for session in values(s:sessions)
    if session.contains_file(path)
      return 1
    endif
  endfor
  return 0
endfunction

function! activefix#is_need_updating(path)
  return &modified
endfunction

function! activefix#kill_file_session(path)
  let path = activefix#unify_path(a:path)
  for [key, session] in items(s:sessions)
    if session.contains_file(path)
      call s:dispose_session(key)
    endif
  endfor
endfunction

" if filereadable(expand('<sfile>:r') . '.VIM')
"   function! activefix#unify_path(path)
"     " Note: On windows, vim can't expand path names from 8.3 formats.
"     " So if getting full path via <sfile> and $HOME was set as 8.3 format,
"     " vital load duplicated scripts. Below's :~ avoid this issue.
"     return tolower(fnamemodify(resolve(fnamemodify(
"     \              a:path, ':p:gs?[\\/]\+?/?')), ':~'))
"   endfunction
" else
"   function! activefix#unify_path(path)
"     return resolve(fnamemodify(a:path, ':p:gs?[\\/]\+?/?'))
"   endfunction
" endif

function! activefix#unify_path(path)
  return resolve(fnamemodify(a:path, ':p:gs?[\\/]\+?/?'))
endfunction

function! activefix#reverse_dict(dict)
  let ret = {}
  for [key, value] in items(a:dict)
    let ret[value] = key
  endfor
  return ret
endfunction

" aliases

" Expand wildcards as same as expand().
" When {tempfile} is 1, this function returns
" temporary file instead of actual file name.
" And activefix will pass the temporary file
" to syntax-checker program.
"
" When {expr} starts with '%', return file name
" of target of syntax checking.
" Target file may not be in the current buffer.
"
" NOTE: This function may throws exception
" that name starts with 'activefix'
" And don't catch this exception in configuration function.
"
function! activefix#expand(tempfile, expr)
  return activefix#config#_expand(a:tempfile, a:expr)
endfunction

function! activefix#get_filetype(expr)
  let path = expand(a:expr)
  if bufloaded(path)
    return getbufvar(a:expr, '&filetype')
  else
    " get filetype without buffer option
    let m = filter(values(g:activefix_filetype_pattern), 'path =~? v:val')
    if empty(m)
      return ''
    endif
    let dict = activefix#reverse_dict(g:activefix_filetype_pattern)
    return dict[m[0]]
  endif
endfunction

function! activefix#is_readonly(expr)
  let path = expand(a:expr)
  if bufloaded(path)
    return getbufvar(a:expr, '&readonly') || getbufvar(a:expr, '&nomodifiable')
  else
    return !filewritable(path)
  endif
endfunction

" debug {{{
let g:activefix_debug_exception =
      \ get(g:, 'activefix_debug_exception', 0)

function! activefix#scope()
  return s:
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
