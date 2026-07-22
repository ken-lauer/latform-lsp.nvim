--- Neovim client for the latform language server (Bmad lattice files).
---
--- Registers filetype detection for `*.bmad` / `*.lat` and configures the
--- `latform-lsp` server (go-to-definition, hover, document symbols,
--- diagnostics). On Neovim 0.11+ this uses the native `vim.lsp.config` /
--- `vim.lsp.enable` API; older versions fall back to a `FileType` autocmd.

local M = {}

--- Default configuration. Override any field via |latform-lsp.setup()|.
M.defaults = {
  --- Command used to launch the server (installed by `pip install 'latform[lsp]'`).
  cmd = { "latform-lsp" },
  --- Server log verbosity: "error" | "warning" | "info" | "debug" (nil = server
  --- default). Appended to `cmd` as `--log-level`; logs appear in `:LspLog`.
  log_level = nil,
  --- Write server logs to this file instead of stderr (appended as `--log-file`).
  log_file = nil,
  --- Filetypes the server attaches to.
  filetypes = { "bmad" },
  --- Files/dirs marking a project root, in priority order.
  root_markers = { "pyproject.toml", "latform.toml", ".git" },
  --- Server settings sent via `workspace/didChangeConfiguration`.
  settings = {},
  --- Called after the client attaches to a buffer: `function(client, bufnr)`.
  on_attach = nil,
  --- LSP client capabilities (e.g. from a completion plugin).
  capabilities = nil,
}

--- The merged configuration after |latform-lsp.setup()|; `nil` until then.
M.config = nil

--- Register Bmad lattice files as the `bmad` filetype.
---
--- Covers `*.bmad`, `*.lat`, and the compound `*.lat.bmad` (the latter already
--- matches via its final `.bmad` extension; it is listed explicitly for clarity
--- and to survive any future change to the `bmad` extension mapping).
---
--- Note: the primary detection lives in `ftdetect/bmad.lua`, which Neovim (and
--- lazy.nvim's `ft` handler) source at startup. This function mirrors it for
--- programmatic callers; both are idempotent.
function M.register_filetypes()
  vim.filetype.add({
    extension = {
      bmad = "bmad",
      lat = "bmad",
    },
    pattern = {
      [".*%.lat%.bmad"] = "bmad",
    },
  })
end

--- Build the launch command, appending logging flags from the config.
---
--- @param config table The merged configuration.
--- @return table cmd The command with any `--log-level` / `--log-file` flags.
local function build_cmd(config)
  local cmd = vim.list_extend({}, config.cmd)
  if config.log_level then
    vim.list_extend(cmd, { "--log-level", config.log_level })
  end
  if config.log_file then
    vim.list_extend(cmd, { "--log-file", config.log_file })
  end
  return cmd
end

--- Neovim 0.8–0.10 fallback: start the server from a `FileType` autocmd.
local function enable_legacy(config)
  local group = vim.api.nvim_create_augroup("LatformLsp", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = config.filetypes,
    callback = function(args)
      local fname = vim.api.nvim_buf_get_name(args.buf)
      local root = vim.fs.dirname(vim.fs.find(config.root_markers, {
        path = fname,
        upward = true,
      })[1]) or vim.fs.dirname(fname)
      vim.lsp.start({
        name = "latform",
        cmd = build_cmd(config),
        root_dir = root,
        settings = config.settings,
        on_attach = config.on_attach,
        capabilities = config.capabilities,
      })
    end,
  })
end

--- Configure and enable the latform language server.
---
--- @param opts table|nil Overrides merged over |latform-lsp.defaults|.
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  M.register_filetypes()

  if vim.fn.has("nvim-0.11") == 1 and vim.lsp.config then
    vim.lsp.config("latform", {
      cmd = build_cmd(M.config),
      filetypes = M.config.filetypes,
      root_markers = M.config.root_markers,
      settings = M.config.settings,
      on_attach = M.config.on_attach,
      capabilities = M.config.capabilities,
    })
    vim.lsp.enable("latform")
  else
    enable_legacy(M.config)
  end
end

return M
