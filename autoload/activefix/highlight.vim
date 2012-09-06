let s:save_cpo = &cpo
set cpo&vim

highlight def link activefixError   SpellBad
highlight def link activefixWarning SpellCap

" TODO retreave id as window local
let s:matchid = {}

function! activefix#highlight#clear()
  " call map(keys(s:matchid), 'matchdelete(v:val)')
  " let s:matchid = {}

  for m in getmatches()
    if stridx(m.group, 'activefix') == 0
      call matchdelete(m.id)
    endif
  endfor
endfunction

function! activefix#highlight#set(loclist)
  call activefix#highlight#clear()

  for item in a:loclist
    let group = item.type == 'E' ? 'activefixError' : 'activefixWarning'

    let k = s:highlighting_keyword(item)
    if k !=# ''
      let id = matchadd(group, k)
    elseif has_key(item, 'col')
      let lastcol = col([item.lnum, '$'])
      let lcol = min([lastcol, item.col])
      let id = matchadd(group, '\%' . item.lnum . 'l\%' . lcol . 'c')
    else
      let id = matchadd(group, '\%' . item.lnum . 'l')
    endif

    let s:matchid[id] = k " TODO
  endfor
endfunction

function! s:highlighting_keyword(item)
  if has_key(a:item, 'filename')
    let buf = a:item.filename
  elseif has_key(a:item, 'bufnr')
    let buf = a:item.bufnr
  else
    return ''
  endif

  " TODO カレントバッファが切り替わっていた場合
  if bufnr(buf) != bufnr('%')
    return ''
  endif

  let line = getbufline(buf, a:item.lnum)
  if empty(line)
    return ''
  endif

  let keyword = s:search_keyword(a:item.text)
  if keyword !=# ''
    let pattern = '\<' . keyword . '\>'
    if match(line[0], pattern) >= 0
      return '\%' . a:item.lnum . 'l' . pattern
    endif
  endif
  return ''
endfunction

function! s:search_keyword(message)
  " search quoted word
  let str = matchstr(a:message, '["'']\zs[^'']\+\ze["'']')
  return str
endfunction

function! activefix#highlight#scope()
  return s:
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
