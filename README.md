# colorscheme-file
(I'm not very good at naming things.) This Neovim plugin eases external
scripting of colorscheme changing by allowing a file to control the
colorscheme. It reads from the file on startup and also uses Neovim's libuv to
watch for changes in that file and dynamically change the colorscheme.

## Installation
However you like to install plugins
```lua
-- packer.nvim
use 'eriedaberrie/colorscheme-file.nvim'
```
```vim
" vim-plug
Plug 'eriedaberrie/colorscheme-file.nvim'
```

## Usage and configuration
For a minimal setup, put the following snippet in your `init.lua`. (If your
colorscheme has configuration, do that before running this because it loads the
colorscheme.)
```lua
require('colorscheme-file').setup()
```

The file used defaults to `stdpath('data')/colorscheme-file`
(`~/.local/state/nvim/colorscheme-file` on Unix systems). From here, simply put
the desired theme name in the file and Neovim's colorscheme should change.

The following configuration options are available:
```lua
require('colorscheme-file').setup {
    fallback = 'gruvbox',   -- fallback colorscheme if the one in the file doesn't work
    path = '/path/to/file', -- path to file (defaults to stdpath('data')/colorscheme-file)
    silent = true,          -- doesn't send error messages when enabled (defaults to false)
    aliases = {             -- table of strings that can be used in place of the full colorscheme name
        cm = 'catppuccin-macchiato',
    },
}
```

## Demo

![colorscheme-file-nvim-demo](https://user-images.githubusercontent.com/64395218/204944391-d7eb666a-e417-4eeb-a468-8bf0f1e28c54.gif)
