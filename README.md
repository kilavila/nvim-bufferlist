# Buffer List

<img src="./nvim-bufferlist.jpg" />

My first Neovim plugin

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

<a href="https://dotfyle.com/plugins/kilavila/nvim-bufferlist">
	<img src="https://dotfyle.com/plugins/kilavila/nvim-bufferlist/shield?style=flat" />
</a>

## Todo
Features
- Open/create new buffers
