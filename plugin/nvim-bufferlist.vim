if exists('g:loaded_nvim_bufferlist') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

hi def link BufferListHeader      Number


command! BufferList lua require'nvim-bufferlist'.bufferlist()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_bufferlist = 1
