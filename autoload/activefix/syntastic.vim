let s:save_cpo = &cpo
set cpo&vim

let s:syntastic_overwrite = {
      \ }

let g:activefix_syntastic_overwrite = get(g:, 'activefix_syntastic', {})
call extend(g:activefix_syntastic_overwrite, s:syntastic_overwrite, 'keep')


function! activefix#syntastic#expand_target(type, expr)
  " TODO support argument "nosuf", "liist"

  if a:expr =~# '^%'
    " NOTE: return tempfile instead of current file
    return activefix#config#_expand(1, a:expr)
  else
    return expand(a:expr)
  endif
endfunction

" function! activefix#syntastic#shellescape(expr, ...)
"   return call('shellescape', [a:expr] + a:000)
" endfunction

function! activefix#syntastic#load_checker(checkers, ft)
  let opt_name = "g:syntastic_" . a:ft . "_checker"
  if !exists(opt_name)
    for checker in a:checkers
      if executable(checker)
        let {opt_name} = checker
        break
      endif
    endfor
  endif
endfunction


" this function returns dictionary or 0.
" a:filetype: filetype or filetype/subtype (eg. "python/pyflakes")
"
function! activefix#syntastic#get_config(filetype)
  let filetype = substitute(a:filetype, '-', '_', 'g')

  let [type, config] = s:get_syntastic_config('syntastic', filetype)
  if type is 0
    return
  endif

  " remove temporary environment variable from command.
  " NOTE: vimproc can't pass temporary environment variable
  " NOTE: not support csh/tcsh style (env VAR=)
  " TODO support rvalue
  let m = matchlist(config.makeprg, '^\(\w\+\)=\s\+\(.*\)')
  if !empty(m)
    let config.env = { '$' . m[1] : '' }
    let config.makeprg = m[2]
  endif

  return extend(config, get(g:activefix_syntastic_overwrite, type, {}))
endfunction

function! s:get_syntastic_config(module, filetype)
  if a:filetype =~? '/' " if contains slash
    " need to :source {filetype}.vim
    let filetype = matchstr(a:filetype, '^[^/]\+')
    execute 'runtime activefix/syntastic/' . filetype . '.vim'

    " try {filetype}/{subtype}.vim
    let type = substitute(a:filetype, '/', '#', 'g')
    unlet! config
    let config = s:call_func(printf('activefix#%s#%s#config', a:module, type))
    if config isnot 0
      return [a:filetype, config]
    else
      return [0, 0]
    endif
  endif

  " try {filetype}.vim
  unlet! config
  let config = s:call_func(printf('activefix#%s#%s#config', a:module, a:filetype))
  if config isnot 0
    return [a:filetype, config]
  endif

  " try to get syntastic option variable
  let type = s:get_syntastic_type_var(a:filetype)

  if type !=# ''
    unlet! config
    let config = s:call_func(printf('activefix#%s#%s#%s#config', a:module, a:filetype, type))
    if config isnot 0
      return [a:filetype . '/' . type, config]
    endif
  endif

  " use first of {filetype}/{subtype}.vim
  let list = split(globpath(&runtimepath, 
        \ printf('autoload/activefix/%s/%s/*.vim', a:module, a:filetype)), '\n,')

  for path in list
    let type = fnamemodify(path, ':t:r')

    unlet! config
    let config = s:call_func(printf('activefix#%s#%s#%s#config', a:module, a:filetype, type))
    if config isnot 0
      return [a:filetype . '/' . type, config]
    endif
  endfor

  return [0, 0]
endfunction

function! s:get_syntastic_type_var(filetype)
  let list = [
        \ printf('syntastic_%s_checker', a:filetype),
        \ printf('syntastic_%s_exec', a:filetype),
        \ ]

  for var in list
    let checker = get(g:, var, '')
    if checker !=# ''
      return checker
    endif
  endfor

  return ''
endfunction

function! s:call_func(func, ...)
  call activefix#config#reset()

  let file = substitute(a:func, '#\w\+$', '', 'g')
  let file = substitute(file, '#', '/', 'g')
  execute 'runtime autoload/' . file . '.vim'

  if exists('*' . a:func)
    return call(a:func, a:000)
  else
    return 0
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
