-- Claude Code CLI in a terminal split, live inside Neovim.
-- Reuses your existing `claude` CLI login -- no separate API key needed.
-- Auto-reloads buffers when Claude edits files on disk.
--
-- Keymaps live under the shared <leader>a "AI" group alongside Avante.
-- Uppercase mirrors Avante's lowercase equivalents (e.g. at = Avante toggle,
-- aT = Claude Code toggle) since Avante's own setup() already claims most
-- lowercase letters here.

vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/greggh/claude-code.nvim',
}

require('claude-code').setup {
  window = {
    position = 'vertical botright',
    split_ratio = 0.4,
  },
  keymaps = {
    toggle = {
      normal = '<leader>aT',
      variants = {
        continue = '<leader>aC',
        verbose = false,
      },
    },
  },
}
