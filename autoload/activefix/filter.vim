let s:save_cpo = &cpo
set cpo&vim

function! activefix#filter#convert_path(loclist, mapping)
  let nrdict = s:make_bufnr_dict(a:mapping)

  let ret = deepcopy(a:loclist)
  for i in range(len(ret))
    if ret[i].valid
      if has_key(nrdict, ret[i].bufnr)
        let ret[i].filename = nrdict[ret[i].bufnr]
        unlet ret[i].bufnr
      elseif has_key(a:mapping, get(ret[i], 'filename', ''))
        let ret[i].filename = a:mapping[ret[i].filename]
      endif
    endif
  endfor

  return ret
endfunction

function! s:make_bufnr_dict(mapping)
  let ret = {}
  for [temp, path] in items(a:mapping)
    if bufexists(temp)
      let ret[bufnr(temp)] = path
    endif
  endfor
  return ret
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
