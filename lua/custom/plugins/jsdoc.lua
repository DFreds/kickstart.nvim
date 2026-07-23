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

-- neogen resolves the `any` type (what <leader>cd uses) by building a
-- node-type -> category lookup with pairs(), whose order is randomized per
-- process. The bundled TS/JS config lists some node types under two categories
-- (e.g. `function_declaration` under both `func` and `class`), so they resolve
-- at random -- which is why file-level functions intermittently produced a
-- @class block instead of @param/@returns. Keep each node type in a single
-- category so resolution is deterministic. `parent.func` is left untouched, so
-- functions, arrows, and methods all still resolve to `func`.
local langs = require('neogen.config').get().languages
for _, ft in ipairs { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' } do
  langs[ft].parent.class = { 'class_declaration', 'export_statement' }
  langs[ft].parent.type = {}
end
