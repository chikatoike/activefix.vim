let s:save_cpo = &cpo
set cpo&vim

function! activefix#compiler#get_config(compiler)
  let config = s:try_compiler_plugin(a:compiler)
  if config is 0
    return 0
  endif

  let config.makeprg = s:substisute_command(config.makeprg)
  return config
endfunction

function! s:try_compiler_plugin(compiler)
  if a:compiler ==# ''
    return 0
  endif

  let backup = [&errorformat, &makeprg]
  try
    execute 'compiler' a:compiler
    return { 'errorformat': &errorformat, 'makeprg': &makeprg }
  catch /^Vim\%((\a\+)\)\=:E666:/ " Do not support this compiler.
    return 0
  finally
    let [&errorformat, &makeprg] = backup
  endtry
endfunction

function! s:substisute_command(command)
  let file = activefix#config#_expand(1, '%')
  let command = substitute(a:command, '\\\@<!%', '\=file', 'g')
  return command

  " let command = a:config.makeprg
  " " Optional argument. "$*"
  " let command = substitute(command, '\$\*', get(a:config, 'arg', ''), 'g')
  " " expand "%"
  " let command = substitute(command, '\\\@<!%', '\=a:currentfile', 'g')
  " return command
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
