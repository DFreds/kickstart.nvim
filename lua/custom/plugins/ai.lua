-- AI tooling to make Neovim feel like Cursor:
--   copilot.lua  -> Cursor-style inline (ghost text) tab completion
--   avante.nvim  -> Cursor-style AI chat sidebar + inline edits
--
-- Avante reuses your Copilot authentication (provider = 'copilot'), so no extra
-- API key is required. Run `:Copilot auth` once after first launch to sign in.
-- To switch to Claude/OpenAI later, change `provider` below and set the API key.

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

-- [[ Avante: AI chat + inline edits (the "Cursor" experience) ]]
-- Recommended editor options for Avante's UI.
vim.o.laststatus = 3

vim.pack.add {
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/HakonHarnes/img-clip.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}

require('img-clip').setup {
  default = {
    embed_image_as_base64 = false,
    prompt_for_file_name = false,
    drag_and_drop = { insert_mode = true },
    use_absolute_path = true, -- required on Windows
  },
}

require('render-markdown').setup {
  file_types = { 'markdown', 'Avante' },
}

-- Build Avante's native helper after it is installed/updated. On Windows this
-- runs the bundled Build.ps1 (downloads prebuilt binaries). Registered before
-- `vim.pack.add` so the build completes during installation, before setup().
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('custom-avante-build', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name ~= 'avante.nvim' then return end
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end

    local cmd
    if vim.fn.has 'win32' == 1 then
      cmd = { 'powershell', '-ExecutionPolicy', 'Bypass', '-File', 'Build.ps1', '-BuildFromSource', 'false' }
    else
      cmd = { 'make' }
    end

    local result = vim.system(cmd, { cwd = ev.data.path }):wait()
    if result.code ~= 0 then vim.notify('Avante build failed:\n' .. (result.stderr or result.stdout or ''), vim.log.levels.ERROR) end
  end,
})

vim.pack.add {
  'https://github.com/yetone/avante.nvim',
}

-- NOTE: The copilot provider reads your Copilot OAuth token during setup(), so
-- this call fails until you have run `:Copilot auth` at least once. We guard it
-- with pcall so a fresh (unauthenticated) install still loads the rest of the
-- config; after authenticating, restart Neovim and Avante will initialize.
local ok, err = pcall(function()
  require('avante').setup {
    provider = 'copilot',
    providers = {
      copilot = {
        model = 'gpt-4o-2024-11-20',
      },
    },
  }
end)

if not ok then
  vim.notify('avante.nvim not initialized yet. Run `:Copilot auth`, then restart Neovim.\n(' .. tostring(err) .. ')', vim.log.levels.WARN)
end
