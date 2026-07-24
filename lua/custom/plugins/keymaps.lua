-- Keybindings mirroring c:/Users/dcfre/AppData/Roaming/Cursor/User/settings.json
-- (VSCodeVim), remapped to their Neovim equivalents in this setup.
-- Every mapping carries a `desc` so it shows up in the which-key popup, and all
-- <leader> prefixes are registered as named groups at the bottom of this file.

local ok_telescope, telescope = pcall(require, 'telescope.builtin')
if not ok_telescope then
  vim.notify('telescope.builtin failed to load; telescope-based keymaps disabled.', vim.log.levels.WARN)
  telescope = setmetatable({}, {
    __index = function()
      return function() vim.notify('Telescope is not available.', vim.log.levels.WARN) end
    end,
  })
end

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- ============================================================
-- Normal-mode global bindings
-- ============================================================

-- Select all / save / redo / undo
map('n', '<C-a>', 'ggVG', 'Select all')
map({ 'n', 'i', 'v' }, '<C-s>', '<cmd>write<cr>', 'Save file')
map('n', 'U', '<C-r>', 'Redo')
map('n', '<C-z>', 'u', 'Undo')
map('i', '<C-z>', '<C-o>u', 'Undo')

-- Center screen after large cursor movements (H/M/L + zz)
map({ 'n', 'x' }, 'H', 'Hzz', 'Top of screen (centered)')
map({ 'n', 'x' }, 'M', 'Mzz', 'Middle of screen (centered)')
map({ 'n', 'x' }, 'L', 'Lzz', 'Bottom of screen (centered)')

-- After paste, move cursor to the end of the pasted text
map('n', 'p', 'p`]', 'Paste (cursor to end)')

-- LSP / navigation (matching Cursor's g and K binds)
map('n', 'K', vim.lsp.buf.hover, 'Hover documentation')
map('n', 'gi', telescope.lsp_implementations, 'Goto implementation')
map('n', 'gd', telescope.lsp_definitions, 'Goto definition')
map('n', 'gb', '<C-o>', 'Navigate back')
map('n', 'gf', '<C-i>', 'Navigate forward')

-- Diagnostics navigation ([d / ]d). ([c / ]c hunk nav come from gitsigns.)
map('n', ']d', function() vim.diagnostic.jump { count = 1 } end, 'Next diagnostic')
map('n', '[d', function() vim.diagnostic.jump { count = -1 } end, 'Previous diagnostic')

-- ============================================================
-- <leader> bindings (grouped like the Cursor config)
-- ============================================================

-- G: Git
map('n', '<leader>Ga', function() require('gitsigns').toggle_current_line_blame() end, 'Toggle blame')

-- z: Zen
map('n', '<leader>zz', '<cmd>ZenMode<cr>', 'Toggle Zen mode')

-- r: Refactor
map('n', '<leader>rr', vim.lsp.buf.code_action, 'Refactor (code action)')
map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')

-- s: Search
map('n', '<leader>ss', telescope.commands, 'Command palette')
map('n', '<leader>sr', telescope.lsp_references, 'Find references')
map('n', '<leader>sf', telescope.live_grep, 'Find in files')

-- c: Code
map({ 'n', 'v' }, '<leader>cf', function() require('conform').format { async = true, lsp_format = 'fallback' } end, 'Format document')
map('n', '<leader>ca', vim.lsp.buf.code_action, 'Quick fix (code action)')
map('n', '<leader>co', function()
  vim.lsp.buf.code_action {
    context = { only = { 'source.organizeImports' }, diagnostics = {} },
    apply = true,
  }
end, 'Organize imports')
map('n', '<leader>cd', function() require('neogen').generate {} end, 'Generate doc comment')

-- f: Find
map('n', '<leader>ff', telescope.find_files, 'Quick open (files)')
map('n', '<leader>fr', telescope.oldfiles, 'Open recent')

-- w: Window
-- Move the current *buffer* into the window in the given direction, the way
-- Cursor's "Move Editor into Group" works. If no window exists that way a new
-- split is created to hold it; otherwise the existing window is reused and
-- whatever it was showing becomes hidden. The source window falls back to its
-- alternate buffer, or closes if there is nothing left for it to show.

-- Buffer the source window should display once the current one leaves it: its
-- alternate if that still exists, else the most recently used other buffer.
local function fallback_buf(exclude)
  local alt = vim.fn.bufnr '#'
  if alt ~= -1 and alt ~= exclude and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then return alt end

  local best, best_used = nil, -1
  for _, info in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
    if info.bufnr ~= exclude and info.lastused > best_used then
      best, best_used = info.bufnr, info.lastused
    end
  end
  return best
end

local split_cmd = {
  h = 'leftabove vsplit',
  l = 'rightbelow vsplit',
  k = 'leftabove split',
  j = 'rightbelow split',
}

local function move_buffer(dir)
  local src_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(src_win)

  -- Only real file buffers move; leave the explorer, terminals, etc. put.
  if vim.bo[buf].buftype ~= '' then
    vim.notify('Not a movable buffer.', vim.log.levels.WARN)
    return
  end

  -- winnr(dir) returns the current window when there is nothing that way.
  local target_win
  local target_nr = vim.fn.winnr(dir)
  if target_nr ~= vim.fn.winnr() then
    local win = vim.fn.win_getid(target_nr)
    -- Never drop a buffer into the explorer or a terminal; split instead.
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == '' then target_win = win end
  end

  local fallback = fallback_buf(buf)
  if not target_win and not fallback then
    -- Splitting would just clone the buffer and then collapse back again.
    vim.notify('No other buffer to leave behind.', vim.log.levels.WARN)
    return
  end

  if target_win then
    vim.api.nvim_win_set_buf(target_win, buf)
  else
    vim.cmd(split_cmd[dir]) -- the new window inherits the current buffer
    target_win = vim.api.nvim_get_current_win()
  end

  if fallback then
    vim.api.nvim_win_set_buf(src_win, fallback)
  else
    vim.api.nvim_win_close(src_win, false)
  end

  vim.api.nvim_set_current_win(target_win)
  pcall(vim.api.nvim_win_set_cursor, target_win, cursor)
end

map('n', '<leader>wh', function() move_buffer 'h' end, 'Move buffer left')
map('n', '<leader>wl', function() move_buffer 'l' end, 'Move buffer right')
map('n', '<leader>wj', function() move_buffer 'j' end, 'Move buffer down')
map('n', '<leader>wk', function() move_buffer 'k' end, 'Move buffer up')
map('n', '<leader>wv', '<cmd>split<cr>', 'Split below')
map('n', '<leader>ws', '<cmd>vsplit<cr>', 'Split right')

-- n: Explorer (neo-tree)
map('n', '<leader>nn', '<cmd>Neotree focus<cr>', 'Focus explorer')
map('n', '<leader>nt', '<cmd>Neotree toggle<cr>', 'Toggle explorer')
map('n', '<leader>nf', '<cmd>Neotree reveal<cr>', 'Reveal in explorer')

-- b: Buffer
map('n', '<leader>bd', function() require('mini.bufremove').delete(0, false) end, 'Close buffer')
map('n', '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', 'Close other buffers')
map('n', '<leader>bA', function()
  local bufremove = require 'mini.bufremove'
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then bufremove.delete(buf, false) end
  end
end, 'Close all buffers')
map('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', 'Pin/unpin buffer')
map('n', '<leader>bP', '<cmd>BufferLineTogglePin<cr>', 'Pin/unpin buffer')

-- t: Terminal
map('n', '<leader>tt', '<cmd>ToggleTerm<cr>', 'Toggle terminal')

-- d: Debug
-- kickstart's debug plugin binds <leader>b/<leader>B to breakpoints, which
-- collides with the Buffer group. Move debugging under <leader>d instead.
pcall(vim.keymap.del, 'n', '<leader>b')
pcall(vim.keymap.del, 'n', '<leader>B')
map('n', '<leader>dc', function() require('dap').continue() end, 'Continue')
map('n', '<leader>di', function() require('dap').step_into() end, 'Step into')
map('n', '<leader>dO', function() require('dap').step_over() end, 'Step over')
map('n', '<leader>do', function() require('dap').step_out() end, 'Step out')
map('n', '<leader>db', function() require('dap').toggle_breakpoint() end, 'Toggle breakpoint')
map('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, 'Conditional breakpoint')
map('n', '<leader>du', function() require('dapui').toggle() end, 'Toggle debug UI')
map('n', '<leader>dt', function() require('dap').terminate() end, 'Terminate')

-- Buffer cycling ([b / ]b)
map('n', '[b', '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer')
map('n', ']b', '<cmd>BufferLineCycleNext<cr>', 'Next buffer')

-- ============================================================
-- Visual-mode bindings
-- ============================================================

-- Keep selection after indenting
map('x', '<', '<gv', 'Indent left (keep selection)')
map('x', '>', '>gv', 'Indent right (keep selection)')

-- Paste over selection without clobbering the register, cursor to end
map('x', 'p', '"_dP`]', 'Paste over (keep register)')

-- Search for the visual selection (visualstar)
map('x', '*', function()
  vim.cmd 'normal! "zy'
  local pat = '\\V' .. vim.fn.escape(vim.fn.getreg 'z', '\\/')
  vim.fn.setreg('/', pat)
  vim.fn.histadd('search', pat)
  vim.o.hlsearch = true
end, 'Search selection')

-- ============================================================
-- which-key group labels (so every prefix is named in the popup)
-- ============================================================
local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add {
    { '<leader>G', group = 'Git' },
    { '<leader>r', group = 'Refactor' },
    { '<leader>c', group = 'Code' },
    { '<leader>f', group = 'Find' },
    { '<leader>w', group = 'Window' },
    { '<leader>n', group = 'Explorer' },
    { '<leader>b', group = 'Buffer' },
    { '<leader>d', group = 'Debug' },
    { '<leader>z', group = 'Zen' },
    { '<leader>a', group = 'AI (Avante + Claude Code)' },
    { '<leader>x', group = 'Diagnostics' },
    { '<leader>S', group = 'Session' },
    { 'gs', group = 'Surround', mode = { 'n', 'x' } },
  }
end
