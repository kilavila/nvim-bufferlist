if exists('g:loaded_nvim_bufferlist') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

hi def link BufferListHeader      Number

command! BufferListOpen lua require'nvim-bufferlist'.bufferlist()
command! BufferListClose lua require'nvim-bufferlist'.close_window()

command! QuickNavOpen lua require'nvim-quicknav'.quicknav()
command! QuickNavAdd lua require'nvim-quicknav'.add_current_file()
command! QuickNavNext lua require'nvim-quicknav'.go_to_next_file()
command! QuickNavPrev lua require'nvim-quicknav'.go_to_prev_file()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_bufferlist = 1
