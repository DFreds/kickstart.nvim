-- Minimap (Cursor's editor.minimap.enabled).
-- Must set vim.g.neominimap before the plugin loads.

vim.g.neominimap = { auto_enable = true }

vim.pack.add {
  'https://github.com/Isrothy/neominimap.nvim',
}

vim.keymap.set('n', '<leader>tm', '<cmd>Neominimap Toggle<cr>', { desc = '[T]oggle [M]inimap' })
