-- Session persistence (folke/persistence.nvim).
-- Keymaps under <leader>S (Session group registered in keymaps.lua).
-- No autoload so mini.starter still shows on empty launch.

vim.pack.add {
  'https://github.com/folke/persistence.nvim',
}

require('persistence').setup {
  options = { dir = vim.fn.expand(vim.fn.stdpath 'state' .. '/sessions/') },
}

vim.keymap.set('n', '<leader>Ss', function() require('persistence').load() end, { desc = 'Restore session (cwd)' })
vim.keymap.set('n', '<leader>Sl', function() require('persistence').load { last = true } end, { desc = 'Restore last session' })
vim.keymap.set('n', '<leader>Sd', function() require('persistence').stop() end, { desc = 'Stop saving session' })
