let s:save_cpo = &cpo
set cpo&vim

let s:allow_tempfile = 1 " TODO
let s:config_stack = []

" NOTE: Don't call this function directly.
" Use activefix#expand instead of this
function! activefix#config#_expand(tempfile, expr)
  let m = matchlist(a:expr, '^\(%\)\(.*\)')
  if empty(m)
    return expand(a:expr)
  endif
  let expr = m[1]
  let modifier = m[2]

  let s:config_stack[0].target[activefix#unify_path(expand(expr))] = ''

  " TODO expr != "%"の場合
  if !getbufvar(expr, '&modified')
    return expand(a:expr)
  endif

  " checking able to create temporary file
  if (!g:activefix_allow_auto_save && !a:tempfile) || !s:allow_tempfile
    throw 'activefix_tempfile_error'
  endif

  let file = expand(expr)
  let path = activefix#unify_path(file)

  if !has_key(s:config_stack[0].temp, path)
    " generate temporary file name
    let fname = 'activefix_' . activefix#create_unique_key() . '_' . file
    let s:config_stack[0].temp[path] = activefix#unify_path(fname)
  else
    let fname = fnamemodify(s:config_stack[0].temp[path], ':.')
  endif

  return fnamemodify(fname, modifier)
endfunction

function! activefix#config#reset()
  if empty(s:config_stack)
    call activefix#config#push()
  else
    let s:config_stack[0] = {}
    let s:config_stack[0].temp = {}
    let s:config_stack[0].target = {}
  endif
endfunction

function! activefix#config#push()
  call insert(s:config_stack, {}, 0)
  let s:config_stack[0].temp = {}
  let s:config_stack[0].target = {}
endfunction

function! activefix#config#pop()
  unlet s:config_stack[0]
endfunction

function! activefix#config#get_config(file, allow_tempfile)
  let s:allow_tempfile = a:allow_tempfile

  let filetype = activefix#get_filetype(a:file)

  if has_key(g:activefix_config, filetype)
    let option = g:activefix_config[filetype]
    if type(option) == type([])
      let list = map(copy(option), 's:make_config(v:val, filetype)')
    else
      let list = [s:make_config(option, filetype)]
    endif
  else
    let list = [s:make_config({}, filetype)]
  endif

  return filter(list, 'v:val isnot 0')
endfunction

function! s:make_config(option, filetype)
  try
    if has_key(a:option, 'type')
      let config = s:get_config_source(a:option.type, a:filetype)
    else
      let config = s:try_config_sources(a:filetype)
    endif
  catch /^activefix_tempfile_error$/
    return 0
  endtry

  if config is 0
    return 0
  endif

  let config.target = keys(s:config_stack[0].target)
  let config.tempfile = deepcopy(s:config_stack[0].temp)
  call activefix#config#reset()

  return s:deepextend(config, a:option)
endfunction

function! s:try_config_sources(filetype)
  call activefix#config#reset()
  let config = activefix#syntastic#get_config(a:filetype)
  if config isnot 0
    return config
  endif
  unlet config

  if g:activefix_use_compiler_plugin
    call activefix#config#reset()
    let config = activefix#compiler#get_config(a:filetype)
    if config isnot 0
      return config
    endif
    unlet config
  endif

  return 0
endfunction

function! s:get_config_source(type, filetype)
  let m = matchlist(a:type, '^\([^/]\+\)/\(.*\)')
  if empty(m)
    return 0
  endif
  let [prefix, type] = m[1 : 2]

  call activefix#config#reset()

  if prefix ==# 'syntastic'
    " "syntastic/{type}"
    return activefix#syntastic#get_config(type)

  elseif prefix ==# 'compiler'
    " TODO b:current_compiler?
    " "compiler/{compiler-plugin}"
    return activefix#compiler#get_config(type)

  elseif prefix ==# 'command'
    " "command/{type}"
    return s:get_command_config(type, a:filetype)

  else
    echoerr 'activefix: not support type:' type
    return 0
  endif
endfunction

function! s:get_command_config(type, filetype)
  let type = substitute(a:type, '/', '#', 'g')
  " TODO error handling
  let config = activefix#command#{type}#config()
  if config is 0
    return 0
  endif

  if !has_key(config, 'errorformat')
    let config.errorformat = s:get_errorformat_only(a:filetype)
  endif

  return config
endfunction

function! s:get_errorformat_only(filetype)
  call activefix#config#push()
  let config = s:try_config_sources(a:filetype)
  call activefix#config#pop()
  if config is 0
    return ''
  endif
  return get(config, 'errorformat', '')
endfunction

" from vim-quickrun/autoload/quickrun/module.vim
let s:list_t = type([])
let s:dict_t = type({})
function! s:deepextend(a, b)
  let type_a = type(a:a)
  if type_a != type(a:b)
    throw ''
  endif
  if type_a == s:list_t
    call extend(a:a, a:b)
  elseif type_a == s:dict_t
    for [k, V] in items(a:b)
      let copied = 0
      if has_key(a:a, k)
        let type_k = type(a:a[k])
        if type_k == type(V) &&
              \  (type_k == s:list_t || type_k == s:dict_t)
          call s:deepextend(a:a[k], V)
          let copied = 1
        endif
      endif
      if !copied
        let a:a[k] = deepcopy(V)
      endif
      unlet V
    endfor
  else
    throw ''
  endif
  return a:a
endfunction


function! activefix#config#scope()
  return s:
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
