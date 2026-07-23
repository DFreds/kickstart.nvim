-- AI tooling to make Neovim feel like Cursor:
--   copilot.lua -> Cursor-style inline (ghost text) tab completion
--
-- Run `:Copilot auth` once to sign in. Credentials are owned by the Copilot
-- language server and live in ~/.config/github-copilot/auth.db (on Windows,
-- %LOCALAPPDATA%\github-copilot\auth.db).
--
-- AI chat is not here -- it runs through claude-code.nvim (see claude-code.lua,
-- <leader>tc), which drives the real Claude Code CLI.
--
-- NOTE: avante.nvim was removed rather than fixed. copilot.lua v3.0.0 moved
-- credentials into auth.db, and avante still reads only the legacy
-- hosts.json/apps.json that the language server no longer writes, so its copilot
-- provider cannot authenticate at all -- see yetone/avante.nvim#3121, open with
-- no fix on upstream main. Reading auth.db back out needs a sqlite3 CLI, which
-- macOS ships and Windows does not, so a bridge would have been Mac-only.
-- Avante was only wanted for inline suggestions anyway, which copilot.lua below
-- already does; avante's own config marks that feature experimental and warns
-- against running it on the copilot provider (yetone/avante.nvim#1048).
--
-- Also previously tried and reverted: avante's Claude provider with
-- auth_type = 'max', which reuses a Claude Pro/Max subscription OAuth token.
-- That is against Anthropic's terms of service (subscription OAuth is
-- restricted to Claude Code/claude.ai) and broke with an "Invalid
-- code_challenge_method" error regardless.

-- [[ GitHub Copilot: inline ghost-text suggestions ]]
vim.pack.add {
  'https://github.com/zbirenbaum/copilot.lua',
}

require('copilot').setup {
  panel = { enabled = false },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    -- We wire up our own <Tab> accept below so it can fall back to a real tab.
    keymap = {
      accept = false,
      next = '<M-]>',
      prev = '<M-[>',
      dismiss = '<C-]>',
    },
  },
  -- Avante's copilot provider needs the standard endpoint config.
  server_opts_overrides = {
    settings = {
      ['github'] = { endpoint = 'https://api.githubcopilot.com' },
    },
  },
}

-- Cursor-style super-tab: accept the Copilot suggestion if one is visible,
-- else jump to the next snippet placeholder (LuaSnip), else insert a real tab.
local copilot_suggestion = require 'copilot.suggestion'
local luasnip = require 'luasnip'

vim.keymap.set('i', '<Tab>', function()
  if copilot_suggestion.is_visible() then
    copilot_suggestion.accept()
  elseif luasnip.locally_jumpable(1) then
    luasnip.jump(1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
  end
end, { desc = 'Copilot / snippet jump / tab' })

vim.keymap.set('i', '<S-Tab>', function()
  if luasnip.locally_jumpable(-1) then
    luasnip.jump(-1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Tab>', true, false, true), 'n', false)
  end
end, { desc = 'Snippet jump back' })

vim.keymap.set('i', '<M-Right>', copilot_suggestion.accept_word, { desc = 'Copilot accept word' })
