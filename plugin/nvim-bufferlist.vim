if exists('g:loaded_nvim_bufferlist') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

hi def link BufferListHeader      Number

command! BufferListOpen lua require'nvim-bufferlist'.bufferlist()
command! BufferListClose lua require'nvim-bufferlist'.close_window()
command! BufferListUpdate lua require'nvim-bufferlist'.update_view()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_bufferlist = 1
