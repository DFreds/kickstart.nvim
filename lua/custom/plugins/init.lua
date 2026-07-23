-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Load the notification UI before anything else. Plugins that call vim.notify
-- while loading (e.g. ai.lua's avante guard) would otherwise reach the builtin
-- cmdline echo, and a multi-line message there forces a "press any key to
-- continue" prompt over the dashboard. Once noice is set up, vim.notify is a
-- floating toast instead. require() caches, so the loop below re-requiring this
-- module is a no-op.
require 'custom.plugins.noice'

-- Iterate over all Lua files in the plugins directory and load them
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('custom.plugins.' .. module)
  end
end
