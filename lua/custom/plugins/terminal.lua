-- Integrated terminal (Cursor's toggle terminal) via toggleterm.nvim
-- https://github.com/akinsho/toggleterm.nvim
-- The <leader>tt keymap is defined in keymaps.lua.

vim.pack.add {
  'https://github.com/akinsho/toggleterm.nvim',
}

require('toggleterm').setup {
  open_mapping = nil,
  direction = 'horizontal',
  size = 15,
  shade_terminals = true,
  start_in_insert = true,
  persist_mode = true,
}

-- Allow jumping out of a terminal window with the same <C-h/j/k/l> used
-- everywhere else, without first pressing <Esc><Esc> to leave terminal mode.
for _, k in ipairs { 'h', 'j', 'k', 'l' } do
  vim.keymap.set('t', '<C-' .. k .. '>', [[<C-\><C-n><C-w>]] .. k, { desc = 'Move focus ' .. k })
end
