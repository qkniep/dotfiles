local lualine = require('lualine')
local bufferline = require('bufferline')

vim.o.showtabline = 2

-- Color table for highlights
-- stylua: ignore
local colors = {
  bg       = '#262626',
  fg       = '#FCE8C3',
  yellow   = '#FBB829',
  cyan     = '#0AAEB3',
  darkblue = '#2C78BF',
  green    = '#519F50',
  orange   = '#F75341',
  violet   = '#E02C6D',
  magenta  = '#FF5C8F',
  blue     = '#68A8E4',
  red      = '#EF2F27',
  brblack  = '#918175',
}
--local colors = {
--  bg       = '#202328',
--  fg       = '#bbc2cf',
--  yellow   = '#ECBE7B',
--  cyan     = '#008080',
--  darkblue = '#081633',
--  green    = '#98be65',
--  orange   = '#FF8800',
--  violet   = '#a9a1e1',
--  magenta  = '#c678dd',
--  blue     = '#51afef',
--  red      = '#ec5f67',
--}

-- Choose color according to neovims mode
local function color_by_mode()
  local mode_color = {
    n = colors.blue,
    i = colors.green,
    v = colors.red,
    [''] = colors.red,
    V = colors.red,
    c = colors.magenta,
    no = colors.blue,
    s = colors.orange,
    S = colors.orange,
    [''] = colors.orange,
    ic = colors.yellow,
    R = colors.violet,
    Rv = colors.violet,
    cv = colors.blue,
    ce = colors.blue,
    r = colors.cyan,
    rm = colors.cyan,
    ['r?'] = colors.cyan,
    ['!'] = colors.blue,
    t = colors.blue,
  }
  return { fg = mode_color[vim.fn.mode()] }
end

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = '',
    section_separators = '',
    theme = {
      normal = { c = { fg = colors.fg, bg = colors.bg } },
      inactive = { c = { fg = colors.fg, bg = colors.bg } },
    },
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- these will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

ins_left {
  function()
    return '▊'
  end,
  color = color_by_mode,
  padding = { left = 0 },
}

ins_left {
  'mode',
  color = color_by_mode,
  padding = { left = 1, right = 2 },
}

ins_left {
  'filetype',
  colored = false,
  color = color_by_mode,
  icon = { color = color_by_mode },
  padding = { right = 1 },
}

ins_left {
  'filesize',
  cond = conditions.buffer_not_empty,
}

--ins_left {
--  'filename',
--  cond = conditions.buffer_not_empty,
--  color = { fg = colors.magenta, gui = 'bold' },
--}

ins_left { 'location' }
ins_left { 'progress' }

ins_left {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
  diagnostics_color = {
    error = { fg = colors.red },
    warn = { fg = colors.yellow },
    info = { fg = colors.blue },
    hint = { fg = colors.green },
  },
}

-- Insert mid section.
ins_left {
  function()
    return '%='
  end,
}

ins_left {
  -- LSP server name
  function()
    local msg = 'No active LSP'
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end,
  icon = '',
  color = function()
    local color = { fg = colors.brblack }
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return color
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return { fg = colors.fg }
      end
    end
    return color
  end,
}

-- Add components to right sections
ins_right {
  'diff',
  symbols = { added = ' ', modified = '柳 ', removed = ' ' },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.yellow },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
}

ins_right {
  'branch',
  icon = '',
  color = { fg = colors.violet, gui = 'bold' },
}

ins_right {
  'o:encoding',
  cond = conditions.hide_in_width,
  color = color_by_mode,
}

ins_right {
  'fileformat',
  icons_enabled = true,
  cond = conditions.hide_in_width,
  color = color_by_mode,
}

ins_right {
  function()
    return '▊'
  end,
  color = color_by_mode,
  padding = { left = 1 },
}

lualine.setup(config)
bufferline.setup {}
