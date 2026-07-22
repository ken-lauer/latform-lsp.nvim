# latform-lsp.nvim

Neovim client for the [latform](https://github.com/ken-lauer/latform) language
server — editor support for **Bmad lattice files** (`*.bmad`, `*.lat`).

Features provided by the server:

- **Go-to-definition** for elements, lines, lists, and constants
- **Hover** documentation
- **Document symbols** (outline / breadcrumbs)
- **Diagnostics** (parse errors + linter warnings), live as you type

## Requirements

- Neovim **0.11+** (uses the native `vim.lsp.config` API; falls back to a
  `FileType` autocmd on 0.8–0.10)
- The `latform-lsp` server on your `PATH`:

  ```sh
  pip install 'latform[lsp]'
  ```

  This pulls in [`pygls`](https://github.com/openlawlibrary/pygls). Verify with
  `latform-lsp` being resolvable (`which latform-lsp`) and
  `:checkhealth latform-lsp`.

## Installation

### lazy.nvim

```lua
{
  "ken-lauer/latform-lsp.nvim",
  ft = { "bmad" },
  opts = {},
}
```

### packer.nvim

```lua
use({
  "ken-lauer/latform-lsp.nvim",
  config = function()
    require("latform-lsp").setup()
  end,
})
```

### Manual

Clone into your `runtimepath` and call `require("latform-lsp").setup()` from
your `init.lua`.

## Configuration

`setup()` accepts a table merged over the defaults:

```lua
require("latform-lsp").setup({
  -- Command used to launch the server.
  cmd = { "latform-lsp" },
  -- Filetypes the server attaches to.
  filetypes = { "bmad" },
  -- Files/dirs marking a project root, in priority order.
  root_markers = { "pyproject.toml", "latform.toml", ".git" },
  -- Server settings.
  settings = {},
  -- Runs after the client attaches to a buffer.
  on_attach = function(client, bufnr) end,
  -- LSP capabilities (e.g. from your completion plugin).
  capabilities = nil,
})
```

If `latform-lsp` lives in a virtualenv that isn't on your `PATH`, point `cmd`
at it directly:

```lua
require("latform-lsp").setup({
  cmd = { "/path/to/venv/bin/latform-lsp" },
})
```

Filetype detection for `*.bmad` / `*.lat` is registered at startup, so those
buffers get the `bmad` filetype (and `!`-comment support) even before the
server attaches.

## Troubleshooting

- `:checkhealth latform-lsp` — verifies the Neovim version and that the server
  executable is resolvable.
- `:LspInfo` — shows whether the `latform` client attached to the buffer.
- `:lua vim.print(vim.lsp.get_clients({ name = "latform" }))` — inspect the
  active client.
