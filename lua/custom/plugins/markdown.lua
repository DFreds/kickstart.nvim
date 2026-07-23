-- In-buffer markdown rendering (headings, lists, code blocks, tables).
-- Originally pulled in as an avante.nvim dependency; kept after avante was
-- removed because it renders ordinary markdown buffers on its own merit.

vim.pack.add {
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}

require('render-markdown').setup {
  file_types = { 'markdown' },
}
