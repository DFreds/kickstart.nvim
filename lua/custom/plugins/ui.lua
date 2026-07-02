-- Cursor-style editor tabs (bufferline) + buffer management helpers.
-- https://github.com/akinsho/bufferline.nvim

vim.pack.add {
  'https://github.com/akinsho/bufferline.nvim',
}

vim.o.showtabline = 2

require('bufferline').setup {
  options = {
    -- Emulate Cursor's editor tabs.
    mode = 'buffers',
    diagnostics = 'nvim_lsp',
    separator_style = 'thin',
    show_buffer_close_icons = true,
    show_close_icon = false,
    always_show_bufferline = true,
    offsets = {
      {
        filetype = 'neo-tree',
        text = 'Explorer',
        highlight = 'Directory',
        separator = true,
      },
    },
  },
}
