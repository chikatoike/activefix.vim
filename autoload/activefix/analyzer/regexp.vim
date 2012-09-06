let s:save_cpo = &cpo
set cpo&vim

let s:analyzer = {}

function! activefix#analyzer#regexp#new()
  return deepcopy(s:analyzer)
endfunction

function! s:analyzer.start(session)
  " pattern1: config.regexp = {'pattern': '\(\f\+\):\(\d\+\):\(.*\)', 'path': 1, 'line':2, 'col':-1, 'text':3, 'type':-1}
  " pattern2: config.regexp = ['\(\f\+\):\(\d\+\):\(.*\)', 1, 2, 3]
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

  " TODO support make's directory stack
  let self.loclist = s:analyze_error(string, self.config.regexp)

  return self.loclist
endfunction

function! s:analyze_error(text, regexp)
  if !has_key(a:regexp, 'path')
    return []
  endif
  " optional key: line, col, text, type

  let path_r = a:regexp.path

  let errors = []
  let pattern = a:regexp.pattern

  let i = 0
  while i >= 0
    let m = matchlist(a:text, pattern, i)
    if empty(m)
      break
    endif

    let dict = {'path': m[path_r]}
    if has_key(a:regexp, 'line')
      let dict.lnum = m[a:regexp.line] + 0
    endif
    if has_key(a:regexp, 'col')
      let dict.col = m[a:regexp.col] + 0
    endif
    if has_key(a:regexp, 'text')
      let dict.text = m[a:regexp.text]
    endif
    if has_key(a:regexp, 'type')
      let dict.type = m[a:regexp.type]
    endif

    call add(errors, dict)
    let i = matchend(a:text, pattern, i)
  endwhile

  return errors
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:sts=2 sw=2
