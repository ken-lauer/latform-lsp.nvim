-- Filetype detection for Bmad lattice files.
--
-- Sourced at startup by Neovim (and early by lazy.nvim's `ft` handler, before
-- the plugin body loads) so `*.bmad`, `*.lat`, and `*.lat.bmad` are recognized
-- as `bmad`. That recognition is what lets a `ft = "bmad"` lazy spec trigger
-- the plugin to load in the first place.
--
-- Kept dependency-free (no `require("latform-lsp")`) on purpose: this file can
-- run before the plugin's `lua/` directory is on the runtimepath, so it must
-- not depend on the plugin's Lua modules. `register_filetypes()` in the main
-- module mirrors this for programmatic callers.
vim.filetype.add({
  extension = {
    bmad = "bmad",
    lat = "bmad",
  },
  pattern = {
    [".*%.lat%.bmad"] = "bmad",
  },
})
