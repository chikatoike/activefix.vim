let s:save_cpo = &cpo
set cpo&vim

let s:file_pair = {}

function! activefix#locationmap#file_pair_new(mapping)
  let locmap = deepcopy(s:file_pair)
  let locmap.mapping = a:mapping
  return locmap
endfunction

function! s:file_pair.convert_gen2org(loclist)
  let nrdict = s:make_bufnr_dict(self.mapping)

  let ret = deepcopy(a:loclist)
  for i in range(len(ret))
    if ret[i].valid
      if has_key(nrdict, ret[i].bufnr)
        let ret[i].filename = nrdict[ret[i].bufnr]
        unlet ret[i].bufnr
      elseif has_key(self.mapping, get(ret[i], 'filename', ''))
        let ret[i].filename = self.mapping[ret[i].filename]
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

let s:sourcemap = {}

if globpath(&runtimepath, 'plugin/sourcemap.vim') !=# ''
  function! activefix#locationmap#sourcemap_new(file)
    let locmap = deepcopy(s:file_pair)
    let locmap.consumer = sourcemap#get_consumer(a:file)
    return locmap
  endfunction
endif

function! s:sourcemap.convert_gen2org(loclist)
  if locmap.consumer is 0
    return a:loclist
  endif

  let ret = deepcopy(a:loclist)
  for i in range(len(ret))
    if ret[i].valid
      let file = activefix#unify_path(get(ret[i], 'filename', bufname(ret[i].bufnr)))

      if file ==? self.consumer._file
        let pos = self.consumer.original_line_for(ret[i].lnum)
        if pos.line >= 0
          unlet ret[i].bufnr
          let ret[i].filename = pos.source
          let ret[i].lnum = pos.line
          " TODO: column
        endif
      endif
    endif
  endfor

  return ret
endfunction

" TODO: buffer region

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
