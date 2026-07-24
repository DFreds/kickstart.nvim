-- Welcome/start page on empty launch (Cursor's workbench.startupEditor: welcomePage).
-- mini.nvim is already installed via init.lua.

local starter = require 'mini.starter'

-- `v:oldfiles` mixes separators on Windows (both `C:\src\...` and `C:/src/...`
-- show up in the same shada), so paths are normalized before any prefix match.
-- Lowercasing only happens on Windows, where the filesystem is case insensitive.
local is_win = vim.fn.has 'win32' == 1
local function norm(path)
  local p = vim.fs.normalize(path)
  return is_win and p:lower() or p
end

-- Repository the session was launched in, falling back to the cwd outside a repo.
local function project_root()
  local cwd = vim.fn.getcwd()
  return vim.fs.root(cwd, '.git') or cwd
end

--- Recent files from `v:oldfiles`, split by whether they live under the project root.
---@param n number Maximum number of items.
---@param inside boolean `true` keeps files under the root, `false` keeps the rest.
local function recent_files(n, inside)
  return function()
    local root = project_root()
    local prefix = norm(root):gsub('/$', '') .. '/'
    local section = inside and 'Recent files (project)' or 'Recent files (elsewhere)'

    local items = {}
    for _, f in ipairs(vim.v.oldfiles) do
      if vim.fn.filereadable(f) == 1 and vim.startswith(norm(f), prefix) == inside then
        -- Project files show their path relative to the root, so the list stays
        -- readable and correct even when nvim was opened in a subdirectory.
        local display = f
        if inside and #f > #prefix then
          display = f:sub(#prefix + 1)
        elseif not inside then
          display = vim.fn.fnamemodify(f, ':~')
        end
        local name = string.format('%s (%s)', vim.fn.fnamemodify(f, ':t'), display)
        table.insert(items, { name = name, action = function() vim.cmd.edit(vim.fn.fnameescape(f)) end, section = section })
        if #items >= n then break end
      end
    end

    if #items == 0 then
      local suffix = inside and 'in this project' or 'outside this project'
      return { { name = 'There are no recent files ' .. suffix, action = '', section = section } }
    end

    return items
  end
end

starter.setup {
  header = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
  ]],
  items = {
    recent_files(8, true),
    recent_files(5, false),
    starter.sections.builtin_actions(),
    -- Session restore for the cwd (persistence.nvim, see session.lua). Required
    -- lazily because that module loads after this one.
    { name = 'Restore session', action = function() require('persistence').load() end, section = 'Builtin actions' },
  },
  footer = '',
}
