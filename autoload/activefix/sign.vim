let s:save_cpo = &cpo
set cpo&vim

let s:first_sign_id = 10000
let s:next_sign_id = s:first_sign_id

if g:activefix_enable_signs
  execute 'sign define activefixError text=' . g:activefix_signs_error_symbol . ' texthl=error'
  execute 'sign define activefixWarning text=' . g:activefix_signs_warning_symbol . ' texthl=todo'
endif

function! activefix#sign#clear(oldsigns)
  for i in a:oldsigns
    execute "sign unplace " i
    call remove(s:bufsignids(), index(s:bufsignids(), i))
  endfor
endfunction

function! activefix#sign#set(loclist)
  let oldsigns = copy(s:bufsignids())

  for item in a:loclist
    if has_key(item, 'filename')
      let file = activefix#unify_path(item.filename)
    elseif has_key(item, 'bufnr')
      let file = activefix#unify_path(bufname(item.bufnr))
    else
      continue
    endif

    let type = item.type == 'E' ? 'activefixError' : 'activefixWarning'
    execute 'sign place' s:next_sign_id 'line=' . item.lnum 'name=' . type 'file=' . file
    call add(s:bufsignids(), s:next_sign_id)
    let s:next_sign_id += 1
  endfor

  call activefix#sign#clear(oldsigns)
  let s:first_sign_id = s:next_sign_id
endfunction

function! s:bufsignids()
  if !exists("b:activefix_sign_ids")
    let b:activefix_sign_ids = []
  endif
  return b:activefix_sign_ids
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
