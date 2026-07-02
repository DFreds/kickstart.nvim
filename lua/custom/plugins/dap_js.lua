-- JavaScript / TypeScript debugging via js-debug-adapter.
-- The adapter binary is installed by Mason (see the ensure_installed list in
-- init.lua). nvim-dap itself is loaded by kickstart.plugins.debug, which is
-- required before custom.plugins, so `require('dap')` is available here.
-- Debug keymaps live under <leader>d in custom/plugins/keymaps.lua.

local ok, dap = pcall(require, 'dap')
if not ok then return end

dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'node',
    args = { vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
  },
}

for _, ft in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
  dap.configurations[ft] = {
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      cwd = '${workspaceFolder}',
    },
    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach',
      processId = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
    },
  }
end
