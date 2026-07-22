--- `:checkhealth latform-lsp` implementation.

local M = {}

local health = vim.health or require("health")
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error = health.error or health.report_error

function M.check()
  start("latform-lsp")

  if vim.fn.has("nvim-0.8") == 0 then
    error("Neovim 0.8+ is required")
  else
    ok("Neovim " .. tostring(vim.version()))
  end

  local config = require("latform-lsp").config
  if config == nil then
    warn('require("latform-lsp").setup() has not been called yet')
    return
  end

  local exe = config.cmd[1]
  if vim.fn.executable(exe) == 1 then
    ok(("server executable found: %s (%s)"):format(exe, vim.fn.exepath(exe)))
  else
    error(("server executable not found on PATH: %s"):format(exe), {
      "Install it with: pip install 'latform[lsp]'",
      "Or point `cmd` at the executable in setup().",
    })
  end
end

return M
