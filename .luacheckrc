-- luacheck config for the single-file Neovim config (nvim/init.lua).
std = "lua54"
globals = { "vim" } -- writable: the config mutates vim.g, vim.o, vim.lsp.util, ...
max_line_length = false
