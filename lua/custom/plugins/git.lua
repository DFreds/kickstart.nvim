-- Full Git client: Neogit (stage/commit/branch/push) + Diffview (diffs/history).
-- Keymaps under the existing <leader>G Git group.

vim.pack.add {
  'https://github.com/NeogitOrg/neogit',
  'https://github.com/sindrets/diffview.nvim',
}

require('neogit').setup {}
require('diffview').setup {}

vim.keymap.set('n', '<leader>Gg', '<cmd>Neogit<cr>', { desc = 'Neogit status' })
vim.keymap.set('n', '<leader>Gd', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview open' })
vim.keymap.set('n', '<leader>Gc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview close' })
vim.keymap.set('n', '<leader>Gh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history' })
vim.keymap.set('n', '<leader>GH', '<cmd>DiffviewFileHistory<cr>', { desc = 'Branch history' })
