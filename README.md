<div align="center">

![tafuta logo](logo.svg)

# tafuta.nvim

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/mistweaverco/tafuta.nvim?style=for-the-badge)](https://github.com/mistweaverco/tafuta.nvim/releases/latest)

[Install](#install) • [Usage](#usage)

<p></p>

A tiny 🤏 wrapper around ripgrep for
making search 🔍 blazingly fast ⚡ and
easy to use 👌 in your favorite editor 🥰.

Tafuta is swahili for "search".

It allows you to search for text in your project.

<p></p>

</div>

## Install

> [!WARNING]
> Requires Neovim 0.10.0+

Via [lazy.nvim](https://github.com/folke/lazy.nvim):

### Configuration

```lua
require('lazy').setup({
  -- blazingly fast ⚡ search 🔍
  {
    'mistweaverco/tafuta.nvim',
    cmd = { "Tf" },
    config = function()
      -- Setup is required, even if you don't pass any options
      require('tafuta').setup({
        -- The user command to run the search e.g. `:Tf <query>`
        user_command = "Tf",
        -- rg options, a lua table of options to pass to rg
        rg_options = nil,
      })
    end,
  },
})
```

## Usage

```
:Tf <search-term>
```
