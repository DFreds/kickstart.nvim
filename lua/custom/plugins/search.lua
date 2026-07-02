-- Project-wide search and replace (grug-far.nvim).
-- Requires ripgrep (same dependency as telescope live_grep).

vim.pack.add {
  'https://github.com/MagicDuck/grug-far.nvim',
}

require('grug-far').setup {}

vim.keymap.set({ 'n', 'x' }, '<leader>sR', function() require('grug-far').open {} end, { desc = 'Search and replace' })
