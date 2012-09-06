let s:save_cpo = &cpo
set cpo&vim

function! activefix#process#set_env(config)
  let env = {}

  if has_key(a:config, 'dir') && a:config.dir !=? getcwd()
    " backup
    let env.dir = getcwd()
    " set current directory
    lcd `=a:config.dir`
  endif

  if has_key(a:config, 'env')
    " backup
    " TODO check exists('$VAR')
    let env.env = map(copy(a:config.env), 'eval(v:key)')
    " set environment variable
    for [var, val] in items(a:config.env)
      execute 'let' var '=' string(val)
    endfor
  endif

  return env
endfunction

function! activefix#process#restore_env(env)
  if has_key(a:env, 'dir') && a:env.dir !=? getcwd()
    lcd `=a:env.dir`
  endif

  if has_key(a:env, 'env')
    for [var, val] in items(a:env.env)
      execute 'let' var '=' string(val)
    endfor
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
