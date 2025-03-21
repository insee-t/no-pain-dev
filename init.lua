vim.opt.laststatus = 3

local nopain = require('nopain')
nopain.setup({
  triggers = {
    -- Leader triggers
    { mode = 'n', keys = '\\' },
    { mode = 'x', keys = '\\' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

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

