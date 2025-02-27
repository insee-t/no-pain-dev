-- require("no-pain").setup()

-- vim.keymap.set("n", "g", ":echo 'Goto'<CR>", { desc = "Goto commands" })
-- vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find files" })
-- Add the custom path to package.path
package.path = package.path .. ";$HOME/.config/nopain/lua/?.lua"
-- require("which-bare")
--
vim.opt.laststatus = 3
  --
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd [[
      highlight WKey guifg=#AFFF00 guibg=#000000 gui=bold
      highlight WLabel guifg=#000000 guibg=#AFFF00 gui=bold
      highlight IArrow guifg=#A884E8 guibg=#000000 gui=bold
      highlight Key guifg=#AF0000 guibg=#8A8A8A gui=bold
      highlight Label guifg=#000000 guibg=#8A8A8A gui=bold
      highlight Arrow guifg=#8A8A8A guibg=#000000 gui=bold
    ]]
  end,
})

local nopain = require('nopain')
nopain.setup({
  triggers = {
    -- Leader triggers
    { mode = 'n', keys = '\\' },
    { mode = 'x', keys = '\\' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'f' },
    { mode = 'x', keys = 'f' },

    -- Marks
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },

    -- Registers
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    nopain.gen_clues.builtin_completion(),
    nopain.gen_clues.g(),
    nopain.gen_clues.marks(),
    nopain.gen_clues.registers(),
    nopain.gen_clues.windows(),
    nopain.gen_clues.z(),
  },
})
-- vim.g.mapleader = " "
