if exists('g:loaded_activefix')
  finish
endif
let g:loaded_activefix = 1

let s:save_cpo = &cpo
set cpo&vim


command! ActiveFixUpdate          call activefix#update()
command! ActiveFixStop            call activefix#stop()
command! ActiveFixEnable          call activefix#set_enable(1)
command! ActiveFixDisable         call activefix#set_enable(0)
command! ActiveFixBufferEnable    call activefix#set_enable_buffer(1, bufnr('%'))
command! ActiveFixBufferDisable   call activefix#set_enable_buffer(0, bufnr('%'))
command! -nargs=* ActiveFixFileTypeEnable  call activefix#set_enable_filetype(1, <q-args> !=# '' ? <q-args> : &filetype)
command! -nargs=* ActiveFixFileTypeDisable call activefix#set_enable_filetype(0, <q-args> !=# '' ? <q-args> : &filetype)

command! -nargs=* ActiveFixMake   call activefix#make(<q-args>)

nnoremap <silent> <Plug>(activefix-update) :<C-u>ActiveFixUpdate<CR>

augroup plugin-activefix-plugin
  autocmd!
  autocmd BufReadPost  * call activefix#_on_bufreadpost()
  autocmd BufWritePost * call activefix#_on_bufwritepost()
  autocmd BufDelete    * call activefix#_on_bufdelete()
  autocmd CursorHold   * call activefix#_on_cursorhold(0)
  autocmd CursorHoldI  * call activefix#_on_cursorhold(1)
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
