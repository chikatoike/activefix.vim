let s:save_cpo = &cpo
set cpo&vim

let g:activefix_make_checksyntax_command =
      \ get(g:, 'activefix_make_checksyntax_command', 'make check-syntax')

let g:activefix_make_checksyntax_makefile =
      \ get(g:, 'activefix_make_checksyntax_makefile', 'Makefile')

let g:activefix_make_checksyntax_findpath =
      \ get(g:, 'activefix_make_checksyntax_findpath', '.;')

function! activefix#command#make#checksyntax#config()
  if g:activefix_make_checksyntax_findpath ==# ''
    let dir = findfile(g:activefix_make_checksyntax_makefile, g:activefix_make_checksyntax_findpath)
  else
    " use &path for searching Makefile
    let dir = findfile(g:activefix_make_checksyntax_makefile)
  endif

  if dir ==# ''
    return 0
  endif
  let dir = activefix#unify_path(fnamemodify(dir, ':p:h'))

  return {
        \ 'makeprg': g:activefix_make_checksyntax_command,
        \ 'dir': dir,
        \ 'env': { '$CHK_SOURCES': activefix#expand(1, '%:p') },
        \ }
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
