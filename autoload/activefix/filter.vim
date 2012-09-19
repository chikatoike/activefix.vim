let s:save_cpo = &cpo
set cpo&vim

function! activefix#filter#convert_path(loclist, mapping)
  let locmap = activefix#locationmap#file_pair_new(a:mapping)
  return locmap.convert_gen2org(a:loclist)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
