let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('activefix').load('Vim.Buffer.Manager')

function! activefix#util#is_cmdwin()
  return s:V.Vim.Buffer.Manager.is_cmdwin()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
