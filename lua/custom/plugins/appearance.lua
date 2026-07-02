-- Cursor settings.json parity: Monokai theme, bracket colorization, color swatches, breadcrumbs.
-- Loads after init.lua's tokyonight, overriding the colorscheme.

-- Monokai Vibrant-style theme (sonokai andromeda variant).
vim.g.sonokai_style = 'andromeda'

vim.pack.add {
  'https://github.com/sainnhe/sonokai',
  'https://github.com/HiPhish/rainbow-delimiters.nvim',
  'https://github.com/catgoose/nvim-colorizer.lua',
  'https://github.com/Bekaboo/dropbar.nvim',
}

vim.cmd.colorscheme 'sonokai'

require('rainbow-delimiters.setup').setup {}

require('colorizer').setup {
  user_default_options = {
    css = true,
    tailwind = true,
  },
}

require('dropbar').setup {}

vim.keymap.set('n', '<leader>;', function() require('dropbar.api').pick() end, { desc = 'Pick breadcrumb' })
