-- Editor motion / navigation enhancements to mirror the Cursor (VSCodeVim) setup:
--   flash.nvim  -> vim.sneak + vim.easymotion
--   marks.nvim  -> vim.showMarksInGutter
--   nvim-spider -> vim.camelCaseMotion
--   zen-mode    -> <leader>zz (keymap lives in keymaps.lua)
--   autosave    -> files.autoSave: onFocusChange

vim.pack.add {
  'https://github.com/folke/flash.nvim',
  'https://github.com/chentoast/marks.nvim',
  'https://github.com/chrisgrieser/nvim-spider',
  'https://github.com/folke/zen-mode.nvim',
}

-- [[ flash.nvim: sneak-like jumps + easymotion-style labels ]]
require('flash').setup {}

local flash = require 'flash'
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() flash.jump() end, { desc = 'Flash jump (sneak)' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() flash.treesitter() end, { desc = 'Flash treesitter select' })
vim.keymap.set('o', 'r', function() flash.remote() end, { desc = 'Flash remote' })
vim.keymap.set({ 'x', 'o' }, 'R', function() flash.treesitter_search() end, { desc = 'Flash treesitter search' })

-- [[ marks.nvim: show marks in the sign column ]]
require('marks').setup {}

-- [[ nvim-spider: camelCase / subword aware w, e, b, ge motions ]]
local spider = require 'spider'
spider.setup { skipInsignificantPunctuation = true }
for _, motion in ipairs { 'w', 'e', 'b', 'ge' } do
  vim.keymap.set({ 'n', 'o', 'x' }, motion, function() spider.motion(motion) end, { desc = 'Spider-' .. motion .. ' (camelCase)' })
end

-- [[ zen-mode: distraction-free editing ]]
require('zen-mode').setup {}

-- [[ Autosave on focus loss / leaving a buffer (Cursor's onFocusChange) ]]
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
  group = vim.api.nvim_create_augroup('custom-autosave', { clear = true }),
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].modified and vim.bo[buf].modifiable and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= '' then
      vim.api.nvim_buf_call(buf, function() vim.cmd 'silent! write' end)
    end
  end,
})
