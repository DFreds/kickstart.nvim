-- Problems / diagnostics panel (trouble.nvim).
-- Keymaps under <leader>x (Diagnostics group registered in keymaps.lua).

vim.pack.add {
  'https://github.com/folke/trouble.nvim',
}

require('trouble').setup {}

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (workspace)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Diagnostics (buffer)' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle<cr>', { desc = 'Symbols' })
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location list' })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix list' })
