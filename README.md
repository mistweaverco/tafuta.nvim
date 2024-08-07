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

![screenshot](https://github.com/user-attachments/assets/dfd41d8f-1ad2-450e-be74-ff049483f603)

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
    -- Make sure this matches the command you want to use and the command pass to setup
    -- as user_command_prompt and user_command_cursor
    -- e.g. if you want to use `:Rg` then the cmd should be `Rg`
    -- If you don't want to use a command, you can omit this option completely
    cmd = { "Tf", "Tfc" },
    config = function()
      -- Setup is required, even if you don't pass any options
      require('tafuta').setup({
        -- The user command to run the search e.g. `:Tf <flags> <query>`
        -- Default: "Tf", but it can be anything you want.
        -- If you don't want a command, you can set it to `nil`
        user_command_prompt = "Tf",
        user_command_cursor = "Tfc",
        -- rg options, a lua table of options to pass to rg,
        -- e.g. { "--hidden", "--no-ignore" }
        -- Default: nil
        -- See `rg --help` for more options
        rg_options = nil,
      })
    end,
  },
})
```

## Usage

You can either search for *any text* or search for the word under the cursor.

### Search for text

Search for text in your project via the command:

```
:Tf <rg-flags> <search-term>
```

or via calling a lua function:

```lua
require('tafuta').run({"[rg-flag1]", "[rg-flag2]", "[search_term]"})
```

#### Example

Search for "Neovim version" in the project:

> [!NOTE]
> You need to escape all spaces in the search term,
> when using the user command.

```
:Tf --hidden --no-ignore Neovim\ version
```

or via calling a lua function:

```lua
require('tafuta').run({"--hidden", "--no-ignore", "Neovim version"})
```

#### Example without flags

Also with default options and without flags:

```
:Tf Neovim\ version
```

or via calling a lua function:

```lua
require('tafuta').run({"Neovim version"})
```

### Search for word under cursor

You can also search for the word under the cursor via:

```
:Tfc
```

or via calling a lua function:

```lua
require('tafuta').cursor()
```
