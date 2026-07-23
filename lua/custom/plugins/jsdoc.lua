-- JSDoc / TSDoc generation, mirroring the VSCode / JetBrains behaviour where a
-- doc block is expanded with @param, @returns, etc. filled in from the
-- signature under the cursor.
--
-- neogen builds the annotation from the treesitter tree, and expands it through
-- LuaSnip so you can <Tab> between the description placeholders.
--
-- Bound to <leader>cd in keymaps.lua, alongside the rest of the Code group.

vim.pack.add { 'https://github.com/danymat/neogen' }

require('neogen').setup {
  snippet_engine = 'luasnip',
  languages = {
    -- JS has no type annotations, so jsdoc's `@param {type} name` is right.
    -- TS already carries the types, so tsdoc's `@param name` avoids repeating
    -- them in the comment.
    javascript = { template = { annotation_convention = 'jsdoc' } },
    javascriptreact = { template = { annotation_convention = 'jsdoc' } },
    typescript = { template = { annotation_convention = 'tsdoc' } },
    typescriptreact = { template = { annotation_convention = 'tsdoc' } },
  },
}
