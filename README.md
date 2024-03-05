# Buffer List
My first ever Neovim plugin

Improved `:ls`

## Features
- List open buffers
- Go to buffers
- Close buffers

## Installation
With [lazy.nvim](https://github.com/folke/lazy.nvim)
```
{ "kilavila/nvim-bufferlist" }
```

## Keymaps
Open window with `:BufferList`

or bind to a key
```
nnoremap <leader>b :BufferList<CR>
```

Keybinds to use in Buffer List window
```
Escape, q = Close window
Enter, l  = Go to buffer
h, d      = Close buffer
```
