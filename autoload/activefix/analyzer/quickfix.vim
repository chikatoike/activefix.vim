let s:save_cpo = &cpo
set cpo&vim

let s:analyzer = {}

function! activefix#analyzer#quickfix#new()
  return deepcopy(s:analyzer)
endfunction

function! s:analyzer.start(session)
  let self.config = deepcopy(a:session.config)
  let self.loclist = []
  let self._result = ''
endfunction

function! s:analyzer.output(data, session)
  let self._result .= a:data
  return []
endfunction

function! s:analyzer.finish(session)
  let string = self._result

  if activefix#util#is_cmdwin()
    return []
  endif

  let self.loclist = s:execute_getexpr(
        \ string, self.config.errorformat,
        \ g:activefix_use_locationlist, 
        \ !g:activefix_enable_quickfix)

  return self.loclist
endfunction

function! s:execute_getexpr(text, errorformat, locationlist, restore)
  let old_errorformat = &errorformat
  let &errorformat = a:errorformat

  let errors = []

  try
    if a:locationlist
      noautocmd silent lgetexpr a:text
      let errors = getloclist(0)
      if a:restore
        noautocmd silent! lolder
      endif
    else
      noautocmd silent cgetexpr a:text
      let errors = getqflist()
      if a:restore
        noautocmd silent! colder
      endif
    endif
  finally
    let &errorformat = old_errorformat
  endtry

  return errors
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
