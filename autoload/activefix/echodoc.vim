let s:save_cpo = &cpo
set cpo&vim

" TODO
if !exists('g:echodoc_activefix_type')
  let g:echodoc_activefix_type = {
        \   'e': 'error',
        \   'E': 'error',
        \   'w': 'warning',
        \   'W': 'warning',
        \   'r': 'remark',
        \   'R': 'remark',
        \ }
endif

" let g:echodoc_activefix_type['e'] = 'error'
" let g:echodoc_activefix_type['E'] = 'error'
" let g:echodoc_activefix_type['w'] = 'warning'
" let g:echodoc_activefix_type['W'] = 'warning'
" let g:echodoc_activefix_type['r'] = 'remark'
" let g:echodoc_activefix_type['R'] = 'remark'

let s:doc_dict = {
      \ 'name' : 'activefix',
      \ 'rank' : 3,
      \ 'filetypes' : {},
      \ }

function! s:doc_dict.search(cur_text)
  if mode() !=# 'n'
    return []
  endif
  let [l:bufnr, l:lnum] = getpos(".")[0:1]
  let l:bufnr = bufnr("%")
  for l:d in getqflist()
    if (l:d.bufnr != l:bufnr || l:d.lnum != l:lnum)
      continue
    endif
    if getline(".") ==# l:d.text
      continue
    endif
    return [{'text': printf('type %s: %s', get(g:echodoc_activefix_type, l:d.type, l:d.type), l:d.text)}]
  endfor
  return []
endfunction

" call echodoc#register(s:doc_dict.name, s:doc_dict)

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
