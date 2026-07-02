-- Command-center UI + pretty notifications (Cursor's window.commandCenter).
-- LSP progress is disabled so fidget.nvim (in init.lua) remains the sole progress UI.

vim.pack.add {
  'https://github.com/folke/noice.nvim',
  'https://github.com/rcarriga/nvim-notify',
}

require('notify').setup {}

require('noice').setup {
  lsp = {
    progress = { enabled = false },
  },
}
