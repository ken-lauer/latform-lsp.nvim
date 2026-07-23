# latform-lsp.nvim

Neovim client for the [latform](https://github.com/ken-lauer/latform) language
server — editor support for **Bmad lattice files** (`*.bmad`, `*.lat`).

Features provided by the server:

- **Go-to-definition** for elements, lines, lists, and constants
- **Find references** across the whole project
- **Hover** — element/constant/line definitions, attribute types & units,
  element-type keywords, and builtin functions & constants
- **Completion** — element types, attributes (for the element's type),
  defined names, and builtin functions/constants, cased to your project's
  format settings
- **Rename** a name and all its references (project-wide)
- **Formatting** — whole document or a selected range
- **Semantic highlighting** — parser-accurate token colors (names, element
  types, attributes, builtins) beyond regex syntax highlighting
- **Document symbols** (outline / breadcrumbs)
- **Diagnostics** (parse errors + linter warnings), live as you type

The server is **project-aware**: with a `latform.toml` declaring `top-level`
lattices (or a `tao.init`), cross-file references resolve across the tree, and
edits to one file re-analyze quickly. Changes to files on disk are picked up
automatically.

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

## Usage

On Neovim 0.11+ the built-in LSP keymaps work out of the box once the client
attaches:

| Mapping | Action |
| --- | --- |
| `grn` | Rename symbol |
| `grr` | Find references |
| `gO` | Document symbols |
| `K` | Hover |
| `[d` / `]d` | Previous / next diagnostic |
| `gq{motion}` | Format range (uses the server's `formatexpr`) |

Go-to-definition isn't mapped by default — add your own, e.g.
`vim.keymap.set("n", "gd", vim.lsp.buf.definition)`. Format the whole buffer
with `:lua vim.lsp.buf.format()`.

**Completion** is provided by the server but Neovim needs a completion engine to
surface it. On 0.11+ you can enable the built-in one per buffer:

```lua
require("latform-lsp").setup({
  on_attach = function(client, bufnr)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end
  end,
})
```

Or point `capabilities` at your completion plugin (e.g. `cmp-nvim-lsp`).

## Configuration

`setup()` accepts a table merged over the defaults:

```lua
require("latform-lsp").setup({
  -- Command used to launch the server.
  cmd = { "latform-lsp" },
  -- Server log verbosity: "error" | "warning" | "info" | "debug" (nil = default).
  -- Logs go to :LspLog. "debug" reports every request the server handles.
  log_level = nil,
  -- Write server logs to this file instead of stderr.
  log_file = nil,
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
- `setup({ log_level = "debug" })` then `:LspLog` — see every request the server
  handles (useful when a feature isn't responding).
- `:lua vim.print(vim.lsp.get_clients({ name = "latform" }))` — inspect the
  active client.
- `:help latform-lsp` — full documentation.

## Development

```sh
make test     # run the test suite (plenary/busted; clones plenary on first run)
make lint     # stylua --check
make format   # stylua (rewrite in place)
```

Tests live in `tests/` and cover the pure-Lua surface (filetype detection and
config merging); the LSP attach path is exercised against the real server.
CI runs stylua and the test matrix (Linux/macOS/Windows × stable/nightly) via
`.github/workflows/lint-test.yml`.
