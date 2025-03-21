local NoPain = {}
local H = {}

NoPain.normal_primary = "#98C066"
NoPain.normal_second = "#1C1C1C"
NoPain.desc_bg = "#8A8A8A"
NoPain.after_emoji_fg = "#3A3A3A"
NoPain.after_emoji_bg = "#1C1C1C"

NoPain.clues_normal = {
    { next_key = 'hjkl', desc = '←↓↑→' },
    { next_key = 'i', desc = 'INSERT' },
    { next_key = 'v', desc = 'VISUAL' },
    { next_key = ':', desc = 'COMMAND' },
    { next_key = 'x', desc = 'Delete Char' },
    { next_key = 'd', desc = 'Delete' },
    { next_key = 'w', desc = 'W Forward' },
    { next_key = '^ v', desc = 'Block' },
}

NoPain.clues_insert = {
    { next_key = '󰘴 h', desc = 'Delete char' },
    { next_key = '󰘴 w', desc = 'Delete word' },
    { next_key = '󰘴 t', desc = 'Indent' },
    { next_key = '󰘴 d', desc = 'Deindent' },
    { next_key = '󰘴 x', desc = 'Completion' },
    { next_key = '󰘴 r', desc = 'Register' },
    { next_key = '󰘴 j', desc = 'Add line' },
    { next_key = '󰘴 o', desc = 'Temp normal mode' },
}

NoPain.clues_visual = {
    { next_key = 'y',  desc = 'yank' },
    { next_key = 'c',  desc = 'change' },
    { next_key = 'iw', desc = 'in word' },
    { next_key = 'o',  desc = 'other end' },
    { next_key = 'ap', desc = 'around par' },
    { next_key = '{',  desc = 'prev empty' },
}

NoPain.create_clues_bar = function(clues)

    local highlights = {
        { "AfterEmoji",  { fg = NoPain.after_emoji_fg, bg = NoPain.after_emoji_bg, bold = false } },
        { "AfterEmoji2",  { fg = NoPain.after_emoji_bg, bg = NoPain.after_emoji_fg, bold = false } },
        { "Default", { fg = NoPain.normal_primary, bg = NoPain.normal_second, bold = false } },
        { "Inverse", { fg = NoPain.normal_second, bg = NoPain.normal_primary, bold = false } },
        { "Arrow",  { fg = NoPain.nopain_secondary, bg = NoPain.nopain_font, bold = false } },
        { "Keys",   { fg = NoPain.normal_primary, bg = NoPain.normal_second, bold = true } },
        { "IArrow", { fg = NoPain.nopain_font, bg = NoPain.nopain_secondary, bold = true } },
        { "Desc",  { fg = NoPain.normal_second, bg = NoPain.desc_bg,  bold = false } },
        { "DescInverse",  { fg = NoPain.desc_bg, bg = NoPain.normal_second,  bold = false } },
        { "WLabel", { fg = "#3B4252", bg = NoPain.nopain_secondary,  bold = false } },
        { "WKey",   { fg = NoPain.nopain_secondary, bg = NoPain.nopain_secondary,  bold = true } },
        { "Key",    { fg = NoPain.nopain_secondary, bg = NoPain.nopain_secondary,  bold = true } },
    }

    for _, hl in ipairs(highlights) do
        vim.api.nvim_set_hl(0, hl[1], hl[2])
    end
    local clues_bar = "%#Inverse# 󰌵 %#Default#%#AfterEmoji2# %#AfterEmoji#"
    for _, line_content in ipairs(clues) do
        clues_bar = clues_bar .. string.format(" %s%s %s%s %s %s%s",
            "%#Keys#", line_content.next_key, "%#Desc#", "",
            line_content.desc,"%#DescInverse#","")
    end
    return clues_bar
end

---- Define a function to check the mode and change statusline according to mode
NoPain.change_statusline_by_mode = function()
  -- Get the current mode
  local current_mode = vim.api.nvim_get_mode().mode

  -- Check if the current mode is "normal" mode (you can change this to other modes)
    if current_mode == "n" then
        -- Echo "Hello" in the command line
        -- vim.api.nvim_command('echo "Hello"')
        NoPain.normal_primary = "#98C066"
        vim.opt.statusline = NoPain.create_clues_bar(NoPain.clues_normal)
    elseif current_mode == "i" then
        NoPain.normal_primary = "#50B2F0"
        vim.opt.statusline = NoPain.create_clues_bar(NoPain.clues_insert)
    elseif current_mode == "v" then
        NoPain.normal_primary = "#F0B100"
        vim.opt.statusline = NoPain.create_clues_bar(NoPain.clues_visual)
    end
end

NoPain.setup = function(config)
    -- Export module
    _G.NoPain = NoPain

    -- Setup config
    config = H.setup_config(config)

    -- Apply config
    H.apply_config(config)

    -- Define behavior
    H.create_autocommands()

    -- Create default highlighting
    H.create_default_hl()

    NoPain.normal_primary = "#98C066"
    vim.opt.statusline = NoPain.create_clues_bar(NoPain.clues_normal)

    -- Set up an autocommand to call the function whenever the mode changes
    vim.api.nvim_create_autocmd('ModeChanged', {
        pattern = '*', -- Trigger for all mode changes
        callback = NoPain.change_statusline_by_mode,
    })

    -- vim.api.nvim_set_keymap('n', 'q', ':lua print("test")<CR>', { noremap = true, silent = true })
end

NoPain.config = {
    -- Array of extra clues to show
    clues = {},

    -- Array of opt-in triggers which start custom key query process.
    -- **Needs to have something in order to show clues**.
    triggers = {},

    -- Clue window settings
    window = {
        -- Floating window config
        config = {},

        -- Delay before showing clue window
        delay = 0,

        -- Keys to scroll inside the clue window
        scroll_down = '<C-d>',
        scroll_up = '<C-u>',
    },
}  

NoPain.enable_all_triggers = function()
    for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
        -- Map only inside valid listed buffers
        if vim.fn.buflisted(buf_id) == 1 then H.map_buf_triggers(buf_id) end
    end
end

NoPain.enable_buf_triggers = function(buf_id)
    buf_id = (buf_id == nil or buf_id == 0) and vim.api.nvim_get_current_buf() or buf_id
    if not H.is_valid_buf(buf_id) then H.error('`buf_id` should be a valid buffer identifier.') end
    H.map_buf_triggers(buf_id)
end

NoPain.disable_all_triggers = function()
    for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
        H.unmap_buf_triggers(buf_id)
    end
end

NoPain.disable_buf_triggers = function(buf_id)
    buf_id = (buf_id == nil or buf_id == 0) and vim.api.nvim_get_current_buf() or buf_id
    if not H.is_valid_buf(buf_id) then H.error('`buf_id` should be a valid buffer identifier.') end
    H.unmap_buf_triggers(buf_id)
end

NoPain.ensure_all_triggers = function()
    NoPain.disable_all_triggers()
    NoPain.enable_all_triggers()
end

NoPain.ensure_buf_triggers = function(buf_id)
    NoPain.disable_buf_triggers(buf_id)
    NoPain.enable_buf_triggers(buf_id)
end

NoPain.set_mapping_desc = function(mode, lhs, desc)
    if type(mode) ~= 'string' then H.error('`mode` should be string.') end
    if type(lhs) ~= 'string' then H.error('`lhs` should be string.') end
    if type(desc) ~= 'string' then H.error('`desc` should be string.') end

    local ok_get, map_data = pcall(vim.fn.maparg, lhs, mode, false, true)
    if not ok_get or type(map_data) ~= "table" or vim.tbl_count(map_data) == 0 then
        local msg = string.format('No mapping found for mode %s and LHS %s.', vim.inspect(mode), vim.inspect(lhs))
        H.error(msg)
    end

    map_data.desc = desc
    local ok_set = pcall(vim.fn.mapset, mode, false, map_data)
    if not ok_set then
        H.error(vim.inspect(desc) .. ' is not a valid description.')
    end
end

NoPain.gen_clues = {}

NoPain.gen_clues.builtin_completion = function()
    --stylua: ignore
    return {
        { mode = 'i', keys = '<C-x><C-d>', desc = 'Defined identifiers' },
        { mode = 'i', keys = '<C-x><C-e>', desc = 'Scroll ↑' },
        { mode = 'i', keys = '<C-x><C-f>', desc = 'File names' },
        { mode = 'i', keys = '<C-x><C-i>', desc = 'Identifiers' },
        { mode = 'i', keys = '<C-x><C-k>', desc = 'dict Identifiers' },
        { mode = 'i', keys = '<C-x><C-l>', desc = 'Whole lines' },
        { mode = 'i', keys = '<C-x><C-n>', desc = 'Next' },
        { mode = 'i', keys = '<C-x><C-o>', desc = 'Omni' },
        { mode = 'i', keys = '<C-x><C-p>', desc = 'Prev' },
        { mode = 'i', keys = '<C-x><C-s>', desc = 'Spell' },
        { mode = 'i', keys = '<C-x><C-t>', desc = 'Thesaurus Idnentifiers' },
        { mode = 'i', keys = '<C-x><C-y>', desc = 'Scroll ↓' },
        { mode = 'i', keys = '<C-x><C-u>', desc = "'completefunc'" },
        { mode = 'i', keys = '<C-x><C-v>', desc = 'Cmd-line' },
        { mode = 'i', keys = '<C-x><C-z>', desc = 'Stop' },
        { mode = 'i', keys = '<C-x><C-]>', desc = 'Tags' },
        { mode = 'i', keys = '<C-x>s',     desc = 'Spell' },
    }
end

NoPain.gen_clues.g = function()
    local gr_clue = vim.fn.has('nvim-0.11') == 1 and { mode = 'n', keys = 'gr', desc = '+LSP' }
      or { mode = 'n', keys = 'gr', desc = 'Virtual replace with character' }
    local gr_clue_viz = vim.fn.has('nvim-0.11') == 1 and { mode = 'x', keys = 'gr', desc = '+LSP' } or {}
  
    --stylua: ignore
    return {
        { mode = 'n', keys = 'g0', desc = 'Leftmost column' },
        { mode = 'n', keys = 'g8', desc = 'Hex value of char' },
        { mode = 'n', keys = 'ga', desc = 'ASCII value' },
        { mode = 'n', keys = 'gD', desc = 'Definition in file' },
        { mode = 'n', keys = 'gd', desc = 'Definition in function' },
        { mode = 'n', keys = 'gE', desc = 'Prev WORD end' },
        { mode = 'n', keys = 'ge', desc = 'Prev word end' },
        { mode = 'n', keys = 'gF', desc = 'Edit + jump line' },
        { mode = 'n', keys = 'gf', desc = 'Edit file' },
        { mode = 'n', keys = 'gg', desc = 'Go to line (default: first)' },
        { mode = 'n', keys = 'gH', desc = 'Select line mode' },
        { mode = 'n', keys = 'gh', desc = 'Select mode' },
        { mode = 'n', keys = 'gI', desc = 'Insert at col 1' },
        { mode = 'n', keys = 'gi', desc = 'Insert at last stop' },
        { mode = 'n', keys = 'gJ', desc = 'Join lines (no spaces)' },
        { mode = 'n', keys = 'gj', desc = 'Down screen line' },
        { mode = 'n', keys = 'gk', desc = 'Up screen line' },
        { mode = 'n', keys = 'gM', desc = 'Middle of text' },
        { mode = 'n', keys = 'gm', desc = 'Middle of screen' },
        { mode = 'n', keys = 'gN', desc = 'Prev search match' },
        { mode = 'n', keys = 'gn', desc = 'Next search match' },
        { mode = 'n', keys = 'go', desc = 'Go to byte' },
        { mode = 'n', keys = 'gP', desc = 'Put before cursor' },
        { mode = 'n', keys = 'gp', desc = 'Put after cursor' },
        { mode = 'n', keys = 'gQ', desc = 'Ex mode' },
        { mode = 'n', keys = 'gq', desc = 'Format (operator)' },
        { mode = 'n', keys = 'gR', desc = 'Virtual Replace' },
        gr_clue,
        { mode = 'n', keys = 'gs', desc = 'Sleep' },
        { mode = 'n', keys = 'gT', desc = 'Prev tab' },
        { mode = 'n', keys = 'gt', desc = 'Next tab' },
        { mode = 'n', keys = 'gU', desc = 'Uppercase (op)' },
        { mode = 'n', keys = 'gu', desc = 'Lowercase (op)' },
        { mode = 'n', keys = 'gV', desc = 'Avoid reselect' },
        { mode = 'n', keys = 'gv', desc = 'Reselect Visual' },
        { mode = 'n', keys = 'gw', desc = 'Format + keep cursor' },
        { mode = 'n', keys = 'gx', desc = 'Exec file' },
        { mode = 'n', keys = 'g<C-]>', desc = '`:tjump` tag' },
        { mode = 'n', keys = 'g<C-a>', desc = 'Mem profile' },
        { mode = 'n', keys = 'g<C-g>', desc = 'Cursor info' },
        { mode = 'n', keys = 'g<C-h>', desc = 'Select block' },
        { mode = 'n', keys = 'g<Tab>', desc = 'Last tab' },
        { mode = 'n', keys = "g'", desc = "Jump to mark (no jumplist)" },
        { mode = 'n', keys = 'g#', desc = 'Search prev word' },
        { mode = 'n', keys = 'g$', desc = 'Rightmost column' },
        { mode = 'n', keys = 'g%', desc = 'Match group' },
        { mode = 'n', keys = 'g&', desc = 'Repeat `:s`' },
        { mode = 'n', keys = 'g*', desc = 'Search word' },
        { mode = 'n', keys = 'g+', desc = 'Newer text' },
        { mode = 'n', keys = 'g,', desc = 'Newer change' },
        { mode = 'n', keys = 'g-', desc = 'Older text' },
        { mode = 'n', keys = 'g;', desc = 'Older change' },
        { mode = 'n', keys = 'g<', desc = 'Prev command output' },
        { mode = 'n', keys = 'g?', desc = 'Rot13 (op)' },
        { mode = 'n', keys = 'g@', desc = "Call 'operatorfunc'" },
        { mode = 'n', keys = 'g]', desc = '`:tselect` tag' },
        { mode = 'n', keys = 'g^', desc = 'Leftmost non-whitespace' },
        { mode = 'n', keys = 'g_', desc = 'Lower line' },
        { mode = 'n', keys = 'g`', desc = "Jump to mark (no jumplist)" },
        { mode = 'n', keys = 'g~', desc = 'Swap case (op)' },
      
        { mode = 'x', keys = 'gf', desc = 'Edit file' },
        { mode = 'x', keys = 'gJ', desc = 'Join lines (no spaces)' },
        { mode = 'x', keys = 'gq', desc = 'Format' },
        gr_clue_viz,
        { mode = 'x', keys = 'gV', desc = 'Avoid reselect' },
        { mode = 'x', keys = 'gw', desc = 'Format + keep cursor' },
        { mode = 'x', keys = 'g<C-]>', desc = '`:tjump` tag' },
        { mode = 'x', keys = 'g<C-a>', desc = 'Increment' },
        { mode = 'x', keys = 'g<C-g>', desc = 'Selection info' },
        { mode = 'x', keys = 'g<C-x>', desc = 'Decrement' },
        { mode = 'x', keys = 'g]', desc = '`:tselect` tag' },
        { mode = 'x', keys = 'g?', desc = 'Rot13' },
      }
  end

NoPain.gen_clues.marks = function()
    local describe_marks = function(mode, prefix)
        local make_clue = function(register, desc) return { mode = mode, keys = prefix .. register, desc = desc } end
        return {
            make_clue('^', 'Latest insert'),
            make_clue('.', 'Latest change'),
            make_clue('"', 'Last exit'),
            make_clue("'", 'Prev line'),
            make_clue('`', 'Prev position'),
            make_clue('[', 'Start change/yank'),
            make_clue(']', 'End change/yank'),
            make_clue('(', 'Start sentence'),
            make_clue(')', 'End sentence'),
            make_clue('{', 'Start paragraph'),
            make_clue('}', 'End paragraph'),
            make_clue('<', 'Start visual'),
            make_clue('>', 'End visual'),
        }
    end

    --stylua: ignore
    return {
        -- Normal mode
        describe_marks('n', "'"),
        describe_marks('n', "g'"),
        describe_marks('n', "`"),
        describe_marks('n', "g`"),

        -- Visual mode
        describe_marks('x', "'"),
        describe_marks('x', "g'"),
        describe_marks('x', "`"),
        describe_marks('x', "g`"),
    }
end

NoPain.gen_clues.registers = function(opts)
    opts = vim.tbl_deep_extend('force', { show_contents = false }, opts or {})

    local describe_registers
    if opts.show_contents then
        describe_registers = H.make_clues_with_register_contents
    else
        describe_registers = function(mode, prefix)
            local make_clue = function(register, desc) return { mode = mode, keys = prefix .. register, desc = desc } end
            return {
                make_clue('0', 'Last yank'),
                make_clue('1', 'Last big del'),
                make_clue('"', 'Default reg'),
                make_clue('#', 'Alt buffer'),
                make_clue('％', 'Current file'),
                make_clue('*', 'Sel clipboard'),
                make_clue('+', 'Sys clipboard'),
                make_clue('-', 'Last small del'),
                make_clue('.', 'Last insert'),
                make_clue('/', 'Last search'),
                make_clue(':', 'Last command'),
                make_clue('=', 'Expr result'),
                make_clue('_', 'Black hole'),
            }
        end
    end

    --stylua: ignore
    return {
        -- Normal mode
        describe_registers('n', '"'),

        -- Visual mode
        describe_registers('x', '"'),

        -- Insert mode
        describe_registers('i', '<C-r>'),

        { mode = 'i', keys = '<C-r><C-r>', desc = '+Insert literally' },
        describe_registers('i', '<C-r><C-r>'),

        { mode = 'i', keys = '<C-r><C-o>', desc = '+Insert literally + not auto-indent' },
        describe_registers('i', '<C-r><C-o>'),

        { mode = 'i', keys = '<C-r><C-p>', desc = '+Insert + fix indent' },
        describe_registers('i', '<C-r><C-p>'),

        -- Command-line mode
        describe_registers('c', '<C-r>'),

        { mode = 'c', keys = '<C-r><C-r>', desc = '+Insert literally' },
        describe_registers('c', '<C-r><C-r>'),

        { mode = 'c', keys = '<C-r><C-o>', desc = '+Insert literally' },
        describe_registers('c', '<C-r><C-o>'),
    }
end

NoPain.gen_clues.windows = function(opts)
    local default_opts = { submode_navigate = false, submode_move = false, submode_resize = false }
    opts = vim.tbl_deep_extend('force', default_opts, opts or {})

    local postkeys_move, postkeys_navigate, postkeys_resize = nil, nil, nil
    if opts.submode_move then postkeys_move = '<C-w>' end
    if opts.submode_navigate then postkeys_navigate = '<C-w>' end
    if opts.submode_resize then postkeys_resize = '<C-w>' end

    --stylua: ignore
    return {
        { mode = 'n', keys = '<C-w>+', desc = '+height', postkeys = postkeys_resize },
        { mode = 'n', keys = '<C-w>-', desc = '-height', postkeys = postkeys_resize },
        { mode = 'n', keys = '<C-w><', desc = '-width', postkeys = postkeys_resize },
        { mode = 'n', keys = '<C-w>>', desc = '+width', postkeys = postkeys_resize },
        { mode = 'n', keys = '<C-w>=', desc = 'same size' },
        { mode = 'n', keys = '<C-w>]', desc = 'split → tag' },
        { mode = 'n', keys = '<C-w>^', desc = 'split → alt file' },
        { mode = 'n', keys = '<C-w>_', desc = 'set height' },
        { mode = 'n', keys = '<C-w>|', desc = 'set width' },
        { mode = 'n', keys = '<C-w>}', desc = 'preview tag' },
        { mode = 'n', keys = '<C-w>b', desc = 'focus bottom', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>c', desc = 'close' },
        { mode = 'n', keys = '<C-w>d', desc = 'split → def' },
        { mode = 'n', keys = '<C-w>F', desc = 'split → edit+jump' },
        { mode = 'n', keys = '<C-w>f', desc = 'split → name+jump' },
        { mode = 'n', keys = '<C-w>g', desc = 'extra actions' },
        { mode = 'n', keys = '<C-w>g]', desc = 'split → tag list' },
        { mode = 'n', keys = '<C-w>g}', desc = ':ptjump' },
        { mode = 'n', keys = '<C-w>g<C-]>', desc = 'split → :tjump' },
        { mode = 'n', keys = '<C-w>g<Tab>', desc = 'focus last tab', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>gF', desc = 'new tab → file+jump' },
        { mode = 'n', keys = '<C-w>gf', desc = 'new tab → file' },
        { mode = 'n', keys = '<C-w>gT', desc = 'focus prev tab', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>gt', desc = 'focus next tab', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>H', desc = 'move leftmost', postkeys = postkeys_move },
        { mode = 'n', keys = '<C-w>h', desc = 'focus left', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>i', desc = 'split → declaration' },
        { mode = 'n', keys = '<C-w>J', desc = 'move bottommost', postkeys = postkeys_move },
        { mode = 'n', keys = '<C-w>j', desc = 'focus down', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>K', desc = 'move topmost', postkeys = postkeys_move },
        { mode = 'n', keys = '<C-w>k', desc = 'focus up', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>L', desc = 'move rightmost', postkeys = postkeys_move },
        { mode = 'n', keys = '<C-w>l', desc = 'focus right', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>n', desc = 'open new' },
        { mode = 'n', keys = '<C-w>o', desc = 'close others' },
        { mode = 'n', keys = '<C-w>P', desc = 'focus preview', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>p', desc = 'focus last', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>q', desc = 'quit' },
        { mode = 'n', keys = '<C-w>R', desc = 'rotate ↑/←', postkeys = postkeys_move },
        { mode = 'n', keys = '<C-w>r', desc = 'rotate ↓/→', postkeys = postkeys_move },
        { mode = 'n', keys = '<C-w>s', desc = 'split horizontal' },
        { mode = 'n', keys = '<C-w>T', desc = 'move to new tab' },
        { mode = 'n', keys = '<C-w>t', desc = 'focus top', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>v', desc = 'split vertical' },
        { mode = 'n', keys = '<C-w>W', desc = 'focus prev', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>w', desc = 'focus next', postkeys = postkeys_navigate },
        { mode = 'n', keys = '<C-w>x', desc = 'swap windows', postkeys = postkeys_move },
        { mode = 'n', keys = '<C-w>z', desc = 'close preview' },
    }
end

NoPain.gen_clues.z = function()
    --stylua: ignore
    return {
        { mode = 'n', keys = 'zA', desc = 'Toggle folds (rec)' },
    { mode = 'n', keys = 'za', desc = 'Toggle fold' },
    { mode = 'n', keys = 'zb', desc = 'Redraw bottom' },
    { mode = 'n', keys = 'zC', desc = 'Close folds (rec)' },
    { mode = 'n', keys = 'zc', desc = 'Close fold' },
    { mode = 'n', keys = 'zD', desc = 'Delete folds (rec)' },
    { mode = 'n', keys = 'zd', desc = 'Delete fold' },
    { mode = 'n', keys = 'zE', desc = 'Eliminate folds' },
    { mode = 'n', keys = 'ze', desc = 'Move cursor right' },
    { mode = 'n', keys = 'zF', desc = 'Create fold' },
    { mode = 'n', keys = 'zf', desc = 'Create fold (op)' },
    { mode = 'n', keys = 'zG', desc = 'Temp mark as correct' },
    { mode = 'n', keys = 'zg', desc = 'Perm mark as correct' },
    { mode = 'n', keys = 'zH', desc = 'Scroll left (½)' },
    { mode = 'n', keys = 'zh', desc = 'Scroll left' },
    { mode = 'n', keys = 'zi', desc = "Toggle 'foldenable'" },
    { mode = 'n', keys = 'zj', desc = 'Next fold start' },
    { mode = 'n', keys = 'zk', desc = 'Prev fold end' },
    { mode = 'n', keys = 'zL', desc = 'Scroll right (½)' },
    { mode = 'n', keys = 'zl', desc = 'Scroll right' },
    { mode = 'n', keys = 'zM', desc = 'Close all folds' },
    { mode = 'n', keys = 'zm', desc = 'Fold more' },
    { mode = 'n', keys = 'zN', desc = "Enable 'foldenable'" },
    { mode = 'n', keys = 'zn', desc = "Reset 'foldenable'" },
    { mode = 'n', keys = 'zO', desc = 'Open folds (rec)' },
    { mode = 'n', keys = 'zo', desc = 'Open fold' },
    { mode = 'n', keys = 'zP', desc = 'Paste (no trail)' },
    { mode = 'n', keys = 'zp', desc = 'Paste (no trail)' },
    { mode = 'n', keys = 'zR', desc = 'Open all folds' },
    { mode = 'n', keys = 'zr', desc = 'Fold less' },
    { mode = 'n', keys = 'zs', desc = 'Scroll cursor left' },
    { mode = 'n', keys = 'zt', desc = 'Redraw top' },
    { mode = 'n', keys = 'zu', desc = 'Undo spelling' },
    { mode = 'n', keys = 'zug', desc = 'Undo `zg`' },
    { mode = 'n', keys = 'zuG', desc = 'Undo `zG`' },
    { mode = 'n', keys = 'zuw', desc = 'Undo `zw`' },
    { mode = 'n', keys = 'zuW', desc = 'Undo `zW`' },
    { mode = 'n', keys = 'zv', desc = 'Open enough folds' },
    { mode = 'n', keys = 'zW', desc = 'Temp mark as wrong' },
    { mode = 'n', keys = 'zw', desc = 'Perm mark as wrong' },
    { mode = 'n', keys = 'zX', desc = 'Update folds' },
    { mode = 'n', keys = 'zx', desc = 'Update + open folds' },
    { mode = 'n', keys = 'zy', desc = 'Yank (no trail) (op)' },
    { mode = 'n', keys = 'zz', desc = 'Redraw center' },
    { mode = 'n', keys = 'z+', desc = 'Redraw under top' },
    { mode = 'n', keys = 'z-', desc = 'Redraw bottom' },
    { mode = 'n', keys = 'z.', desc = 'Redraw center' },
    { mode = 'n', keys = 'z=', desc = 'Spelling suggest' },
    { mode = 'n', keys = 'z^', desc = 'Redraw above' },
    { mode = 'x', keys = 'zf', desc = 'Fold selection' },
    }
end

H.default_config = vim.deepcopy(NoPain.config)

-- Namespaces
H.ns_id = {
    highlight = vim.api.nvim_create_namespace('NoPainHighlight'),
}

-- State of user input
H.state = {
    trigger = nil,
    -- Array of raw keys
    query = {},
    clues = {},
    timer = vim.loop.new_timer(),
    buf_id = nil,
    win_id = nil,
    is_after_postkeys = false,
}

-- Default window config
H.default_win_config = {
    anchor = 'SE',
    border = 'single',
    focusable = false,
    relative = 'editor',
    style = 'minimal',
    width = 30,
    -- Use high enough value to be on top of built-in windows (pmenu, etc.)
    zindex = 251,
}

-- Precomputed raw keys
H.keys = {
    bs = vim.api.nvim_replace_termcodes('<BS>', true, true, true),
    cr = vim.api.nvim_replace_termcodes('<CR>', true, true, true),
    exit = vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true),
    ctrl_d = vim.api.nvim_replace_termcodes('<C-d>', true, true, true),
    ctrl_u = vim.api.nvim_replace_termcodes('<C-u>', true, true, true),
}

-- Timers
H.timers = {
    getcharstr = vim.loop.new_timer(),
}

-- Undo autocommand to be created for several operator tweaks
H.undo_autocommand = 'au ModeChanged * ++once undo!'

-- Helper functionality =======================================================
-- Settings -------------------------------------------------------------------
H.setup_config = function(config)
    -- General idea: if some table elements are not present in user-supplied
    -- `config`, take them from default config
    vim.validate({ config = { config, 'table', true } })
    config = vim.tbl_deep_extend('force', vim.deepcopy(H.default_config), config or {})

    vim.validate({
        clues = { config.clues, 'table' },
        triggers = { config.triggers, 'table' },
        window = { config.window, 'table' },
    })

    local is_table_or_callable = function(x) return type(x) == 'table' or vim.is_callable(x) end
    vim.validate({
        ['window.delay'] = { config.window.delay, 'number' },
        ['window.config'] = { config.window.config, is_table_or_callable, 'table or callable' },
        ['window.scroll_down'] = { config.window.scroll_down, 'string' },
        ['window.scroll_up'] = { config.window.scroll_up, 'string' },
    })

    return config
end

H.apply_config = function(config)
    NoPain.config = config

    -- Create trigger keymaps for all existing buffers
    NoPain.enable_all_triggers()

    -- Tweak macro execution
    local macro_keymap_opts = { nowait = true, desc = "Execute macro without 'nopain' triggers" }
    local exec_macro = function(keys)
        local register = H.getcharstr()
        if register == nil then return end
        NoPain.disable_all_triggers()
        vim.schedule(NoPain.enable_all_triggers)
        pcall(vim.api.nvim_feedkeys, vim.v.count1 .. '@' .. register, 'nx', false)
    end
    vim.keymap.set('n', '@', exec_macro, macro_keymap_opts)

    local exec_latest_macro = function(keys)
        NoPain.disable_all_triggers()
        vim.schedule(NoPain.enable_all_triggers)
        vim.api.nvim_feedkeys(vim.v.count1 .. 'Q', 'nx', false)
    end
    vim.keymap.set('n', 'Q', exec_latest_macro, macro_keymap_opts)
end

H.is_disabled = function(buf_id)
    local buf_disable = H.get_buf_var(buf_id, 'nopain_disable')
    return vim.g.nopain_disable == true or buf_disable == true
end

H.create_autocommands = function()
    local gr = vim.api.nvim_create_augroup('NoPain', {})

    local au = function(event, pattern, callback, desc)
        vim.api.nvim_create_autocmd(event, { group = gr, pattern = pattern, callback = callback, desc = desc })
    end

    -- Ensure buffer-local mappings for triggers are the latest ones to fully
    -- utilize `<nowait>`. Use `vim.schedule_wrap` to allow other events to
    -- create `vim.b.nopain_config` and `vim.b.nopain_disable`.
    local ensure_triggers = vim.schedule_wrap(function(data)
        if not H.is_valid_buf(data.buf) then return end
        NoPain.ensure_buf_triggers(data.buf)
    end)
    -- - Respect `LspAttach` as it is a common source of buffer-local mappings
    local events = { 'BufAdd', 'LspAttach' }
    au(events, '*', ensure_triggers, 'Ensure buffer-local trigger keymaps')
    -- - Respect common interactive not listed filetypes. NOTE: no 'minifiles' as
    --   `'` trigger conflicts with its local `'`. Plus it pollutes `g?` content.
    local special_ft = { 'help', 'git' }
    au('Filetype', special_ft, ensure_triggers, 'Ensure buffer-local trigger keymaps')

    -- Disable all triggers when recording macro as they interfere with what is
    -- actually recorded
    au('RecordingEnter', '*', NoPain.disable_all_triggers, 'Disable all triggers')
    au('RecordingLeave', '*', NoPain.enable_all_triggers, 'Enable all triggers')

    au('VimResized', '*', H.window_update, 'Update window on resize')
    --au('ColorScheme', '*', H.create_default_hl, 'Ensure colors')
end

--stylua: ignore
H.create_default_hl = function()
    local hi = function(name, opts)
        opts.default = true
        vim.api.nvim_set_hl(0, name, opts)
    end

    hi('NoPainBorder', { link = 'FloatBorder' })
    hi('NoPainDescGroup', { link = 'DiagnosticFloatingWarn' })
    hi('NoPainDescSingle', { link = 'NormalFloat' })
    hi('NoPainNextKey', { link = 'DiagnosticFloatingHint' })
    hi('NoPainNextKeyWithPostkeys', { link = 'DiagnosticFloatingError' })
    hi('NoPainSeparator', { link = 'DiagnosticFloatingInfo' })
    hi('NoPainTitle', { link = 'FloatTitle' })
end

H.get_config = function(config, buf_id)
    config = config or {}
    local buf_config = H.get_buf_var(buf_id, 'nopain_config') or {}
    local global_config = NoPain.config

    -- Manually reconstruct to allow array elements to be concatenated
    local res = {
        clues = H.list_concat(global_config.clues, buf_config.clues, config.clues),
        triggers = H.list_concat(global_config.triggers, buf_config.triggers, config.triggers),
        window = vim.tbl_deep_extend('force', global_config.window, buf_config.window or {}, config.window or {}),
    }
    return res
end

H.get_buf_var = function(buf_id, name)
    buf_id = buf_id or vim.api.nvim_get_current_buf()
    if not H.is_valid_buf(buf_id) then return nil end
    return vim.b[buf_id][name]
end

-- Triggers -------------------------------------------------------------------
H.map_buf_triggers = function(buf_id)
    if not H.is_valid_buf(buf_id) or H.is_disabled(buf_id) then return end

    for _, trigger in ipairs(H.get_config(nil, buf_id).triggers) do
        H.map_trigger(buf_id, trigger)
    end
end

H.unmap_buf_triggers = function(buf_id)
    if not H.is_valid_buf(buf_id) or H.is_disabled(buf_id) then return end

    for _, trigger in ipairs(H.get_config(nil, buf_id).triggers) do
        H.unmap_trigger(buf_id, trigger)
    end
end

H.map_trigger = function(buf_id, trigger)
    if not H.is_valid_buf(buf_id) then return end

    -- Compute mapping RHS
    trigger.keys = H.replace_termcodes(trigger.keys)
    local keys_trans = H.keytrans(trigger.keys)

    local rhs = function()
        -- Don't act if for some reason entered the same trigger during state exec
        local is_in_exec = type(H.exec_trigger) == 'table'
            and H.exec_trigger.mode == trigger.mode
            and H.exec_trigger.keys == trigger.keys
        if is_in_exec then
            H.exec_trigger = nil
            return
        end

        -- Start user query
        H.state_set(trigger, { trigger.keys })

        -- Do not advance if no other clues to query. NOTE: it is `<= 1` and not
        -- `<= 0` because the "init query" mapping should match.
        if vim.tbl_count(H.state.clues) <= 1 then return H.state_exec() end

        H.state_advance()
    end

    -- Use buffer-local mappings and `nowait` to make it a primary source of
    -- keymap execution
    local desc = string.format('Query keys after "%s"', keys_trans)
    local opts = { buffer = buf_id, nowait = true, desc = desc }

    -- Create mapping. Use translated variant to make it work with <F*> keys.
    vim.keymap.set(trigger.mode, keys_trans, rhs, opts)
end

H.unmap_trigger = function(buf_id, trigger)
    if not H.is_valid_buf(buf_id) then return end
    pcall(vim.keymap.del, trigger.mode, H.keytrans(trigger.keys), { buffer = buf_id })
end

-- State ----------------------------------------------------------------------
H.state_advance = function(opts)
    opts = opts or {}
    local config_window = H.get_config().window

    -- Show clues: delay (debounce) first show; update immediately if shown or
    -- after postkeys (for visual feedback that extra key is needed to stop)
    H.state.timer:stop()
    local show_immediately = H.is_valid_win(H.state.win_id) or H.state.is_after_postkeys
    local delay = show_immediately and 0 or config_window.delay
    H.state.timer:start(delay, 0, function() H.window_update(opts.same_content) end)

    -- Reset postkeys right now to not flicker when trying to close window during
    -- "not querying" check
    H.state.is_after_postkeys = false

    -- Query user for new key
    local key = H.getcharstr()

    -- Handle key
    if key == nil then return H.state_reset() end

    if key == H.keys.cr then return H.state_exec() end

    local is_window_shown = H.is_valid_win(H.state.win_id)
    local is_scroll_down = key == H.replace_termcodes(config_window.scroll_down)
    local is_scroll_up = key == H.replace_termcodes(config_window.scroll_up)
    if is_window_shown and (is_scroll_down or is_scroll_up) then
        H.window_scroll(is_scroll_down)
        return H.state_advance({ same_content = true })
    end

    if key == H.keys.bs then
        H.state_pop()
    else
        H.state_push(key)
    end

    -- Advance state
    -- - Execute if reached single target keymap
    if H.state_is_at_target() then return H.state_exec() end

    -- - Reset if there are no keys (like after `<BS>`)
    if #H.state.query == 0 then return H.state_reset() end

    -- - Query user for more information if there is not enough
    --   NOTE: still advance even if there is single clue because it is still not
    --   a target but can be one.
    if vim.tbl_count(H.state.clues) >= 1 then return H.state_advance() end

    -- - Fall back for executing what user typed
    H.state_exec()
end

H.state_set = function(trigger, query)
    H.state.trigger = trigger
    H.state.query = query
    H.state.clues = H.clues_filter(H.clues_get_all(trigger.mode), query)
end

H.state_reset = function(keep_window)
    H.state.trigger = nil
    H.state.query = {}
    H.state.clues = {}
    H.state.is_after_postkeys = false

    H.state.timer:stop()
    if not keep_window then H.window_close() end
end

H.state_exec = function()
    -- Compute keys to type
    local keys_to_type = H.compute_exec_keys()

    -- Add extra (redundant) safety flag to try to avoid infinite recursion
    local trigger, clue = H.state.trigger, H.state_get_query_clue()
    H.exec_trigger = trigger
    vim.schedule(function() H.exec_trigger = nil end)

    -- Reset state
    local has_postkeys = (clue or {}).postkeys ~= nil
    H.state_reset(has_postkeys)

    -- Disable trigger !!!VERY IMPORTANT!!!
    -- This is a workaround against infinite recursion (like if `g` is trigger
    -- then typing `gg`/`g~` would introduce infinite recursion).
    local buf_id = vim.api.nvim_get_current_buf()
    H.unmap_trigger(buf_id, trigger)

    -- Execute keys. The `i` flag is used to fully support Operator-pending mode.
    -- Flag `t` imitates keys as if user typed, which is reasonable but has small
    -- downside with edge cases of 'langmap' (like ':\;;\;:') as it "inverts" key
    -- meaning second time (at least in Normal mode).
    vim.api.nvim_feedkeys(keys_to_type, 'mit', false)

    -- Enable trigger back after it can no longer harm
    vim.schedule(function() H.map_trigger(buf_id, trigger) end)

    -- Apply postkeys (in scheduled fashion)
    if has_postkeys then H.state_apply_postkeys(clue.postkeys) end
end

H.state_push = function(keys)
    table.insert(H.state.query, keys)
    H.state.clues = H.clues_filter(H.state.clues, H.state.query)
end

H.state_pop = function()
    H.state.query[#H.state.query] = nil
    H.state.clues = H.clues_filter(H.clues_get_all(H.state.trigger.mode), H.state.query)
end

H.state_apply_postkeys = vim.schedule_wrap(function(postkeys)
    -- Register that possible future querying is a result of postkeys.
    -- This enables (keep) showing window immediately.
    H.state.is_after_postkeys = true

    -- Use `nvim_feedkeys()` because using `state_set()` and
    -- `state_advance()` directly does not work: it doesn't guarantee to be
    -- executed **after** keys from `nvim_feedkeys()`.
    vim.api.nvim_feedkeys(postkeys, 'mit', false)

    -- Defer check of whether postkeys resulted into window.
    -- Could not find proper way to check this which guarantees to be executed
    -- after `nvim_feedkeys()` takes effect **end** doesn't result into flicker
    -- when consecutively applying "submode" keys.
    vim.defer_fn(function()
        if #H.state.query == 0 then H.window_close() end
    end, 50)
end)

H.state_is_at_target = function()
    return vim.tbl_count(H.state.clues) == 1 and H.state.clues[H.query_to_keys(H.state.query)] ~= nil
end

H.state_get_query_clue = function()
    local keys = H.query_to_keys(H.state.query)
    return H.state.clues[keys]
end

H.compute_exec_keys = function()
    local keys_count = vim.v.count > 0 and vim.v.count or ''
    local keys_query = H.query_to_keys(H.state.query)
    local res = keys_count .. keys_query

    local cur_mode = vim.fn.mode(1)

    -- Using `feedkeys()` inside Operator-pending mode leads to its cancel into
    -- Normal/Insert mode so extra work should be done to rebuild all keys
    if vim.startswith(cur_mode, 'no') then
        local operator_tweak = H.operator_tweaks[vim.v.operator] or function(x) return x end
        res = operator_tweak(vim.v.operator .. H.get_forced_submode() .. res)
    elseif not vim.startswith(cur_mode, 'i') and H.get_default_register() ~= vim.v.register then
        -- Force non-default register but not in Insert mode
        local expr_reg_keys = vim.v.register == '=' and (vim.fn.getreginfo('=').regcontents[1] .. '\r') or ''
        res = '"' .. vim.v.register .. expr_reg_keys .. res
    end

    -- `feedkeys()` inside "temporary" Normal mode is executed **after** it is
    -- already back from Normal mode. Go into it again with `<C-o>` ('\15').
    -- NOTE: This only works when Normal mode trigger is triggered in
    -- "temporary" Normal mode. Still doesn't work when Operator-pending mode is
    -- triggered afterwards (like in `<C-o>gUiw` with 'i' as trigger).
    if cur_mode:find('^ni') ~= nil then res = '\15' .. res end

    return res
end

H.operator_tweaks = {
    ['c'] = function(keys)
        -- Doing '<C-\><C-n>' moves cursor one space to left (same as `i<Esc>`).
        -- Solution: add one-shot autocommand correcting cursor position.
        vim.cmd('au InsertLeave * ++once normal! l')
        return H.keys.exit .. '"' .. vim.v.register .. keys
    end,
    ['d'] = function(keys) return '"' .. vim.v.register .. keys end,
    ['y'] = function(keys) return '"' .. vim.v.register .. keys end,
    ['~'] = function(keys)
        if vim.fn.col('.') == 1 then vim.cmd(H.undo_autocommand) end
        return keys
    end,
    ['g~'] = function(keys)
        if vim.fn.col('.') == 1 then vim.cmd(H.undo_autocommand) end
        return keys
    end,
    ['g?'] = function(keys)
        if vim.fn.col('.') == 1 then vim.cmd(H.undo_autocommand) end
        return keys
    end,
    ['!'] = function(keys) return H.keys.exit .. keys end,
    ['>'] = function(keys)
        vim.cmd(H.undo_autocommand)
        return keys
    end,
    ['<'] = function(keys)
        vim.cmd(H.undo_autocommand)
        return keys
    end,
    ['g@'] = function(keys)
        -- Cancelling in-process `g@` operator seems to be particularly hard.
        -- Not even sure why specifically this combination works, but having `x`
        -- flag in `feedkeys()` is crucial.
        vim.api.nvim_feedkeys(H.keys.exit, 'nx', false)
        return H.keys.exit .. keys
    end,
}

H.query_to_keys = function(query) return table.concat(query, '') end

H.query_to_title = function(query) return H.keytrans(H.query_to_keys(query)) end

-- Window ---------------------------------------------------------------------
H.window_update = vim.schedule_wrap(function()
    -- Ensure the state has valid data
    if #H.state.query == 0 then return end

    -- Gather the clue content
    local keys = H.query_to_keys(H.state.query)
    local content = H.clues_to_buffer_content(H.state.clues, keys)

    -- Format the content for the status bar

    --local primaryColor = #868686
    --local secondaryColor = #000000
    local zcolors = {
        fg = "#808080",
        bg = "#00FF00",
        black = "#141414",
         green = "#282828",
        yellow = "#323232",
        blue = "#3C3C3C",
        magenta = "#464646",
        cyan = "#505050",
        white = "#5A5A5A",
        orange = "#FEFEFE"
    }

--label gui bg is behind the description
-- Arrow is the color of arrow after description
-- arrow is bg after w-key mai shai sam liam 
--  I Pai forgroundcolor of label it should effect arrow color bro 
    -- Update the status bar with the clues
    vim.opt.statusline = NoPain.create_clues_bar(content)
end)

H.window_scroll = function(is_scroll_down)
    local scroll_key = is_scroll_down and H.keys.ctrl_d or H.keys.ctrl_u
    local f = function()
        local cache_scroll, bot_line, n_lines = vim.wo.scroll, vim.fn.line('w$'), vim.api.nvim_buf_line_count(0)
        -- Do not scroll past the end of buffer
        local scroll_count = is_scroll_down and math.min(cache_scroll, n_lines - bot_line) or cache_scroll
        if scroll_count > 0 then pcall(vim.cmd, 'normal! ' .. scroll_count .. scroll_key) end
        vim.wo.scroll = cache_scroll
    end
    vim.api.nvim_win_call(H.state.win_id, f)
end

H.window_open = function(config) end

H.window_close = function()
    -- vim.opt.statusline = NoPain.create_clues_bar(NoPain.clu)
    NoPain.change_statusline_by_mode()
end

H.window_get_config = function()
    local has_statusline = vim.o.laststatus > 0
    local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
    -- Remove 2 from maximum height to account for top and bottom borders
    local max_height = vim.o.lines - vim.o.cmdheight - (has_tabline and 1 or 0) - (has_statusline and 1 or 0) - 2

    local buf_id = H.state.buf_id
    local cur_config_fields = {
        row = vim.o.lines - vim.o.cmdheight - (has_statusline and 1 or 0),
        col = vim.o.columns,
        height = math.min(vim.api.nvim_buf_line_count(buf_id), max_height),
        title = H.query_to_title(H.state.query),
    }
    local user_config = H.expand_callable(H.get_config().window.config, buf_id) or {}
    local res = vim.tbl_deep_extend('force', H.default_win_config, cur_config_fields, user_config)

    -- Tweak "auto" fields
    if res.width == 'auto' then res.width = H.buffer_get_width() + 1 end
    res.width = math.min(res.width, vim.o.columns)

    if res.row == 'auto' then
        local is_on_top = res.anchor == 'NW' or res.anchor == 'NE'
        res.row = is_on_top and (has_tabline and 1 or 0) or cur_config_fields.row
    end

    if res.col == 'auto' then
        local is_on_left = res.anchor == 'NW' or res.anchor == 'SW'
        res.col = is_on_left and 0 or cur_config_fields.col
    end

    -- Ensure it works on Neovim<0.9
    if vim.fn.has('nvim-0.9') == 0 then res.title = nil end

    return res
end

-- Buffer ---------------------------------------------------------------------
H.buffer_update = function()
    local buf_id = H.state.buf_id
    if not H.is_valid_buf(buf_id) then buf_id = vim.api.nvim_create_buf(false, true) end

    -- Compute content data
    local keys = H.query_to_keys(H.state.query)
    local content = H.clues_to_buffer_content(H.state.clues, keys)

    -- Add lines
    local lines = {}
    for _, line_content in ipairs(content) do
        table.insert(lines, string.format(' %s │ %s', line_content.next_key, line_content.desc))
    end
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

    -- Add highlighting
    local ns_id = H.ns_id.highlight
    vim.api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)

    local set_hl = function(hl_group, line_from, col_from, line_to, col_to)
        local opts = { end_row = line_to, end_col = col_to, hl_group = hl_group, hl_eol = true }
        vim.api.nvim_buf_set_extmark(buf_id, ns_id, line_from, col_from, opts)
    end

    for i, line_content in ipairs(content) do
        local sep_start = line_content.next_key:len() + 3
        local next_key_hl_group = line_content.has_postkeys and 'NoPainNextKeyWithPostkeys' or 'NoPainNextKey'
        set_hl(next_key_hl_group, i - 1, 0, i - 1, sep_start - 1)

        -- NOTE: Separator '│' is 3 bytes long
        set_hl('NoPainSeparator', i - 1, sep_start - 1, i - 1, sep_start + 2)

        local desc_hl_group = line_content.is_group and 'NoPainDescGroup' or 'NoPainDescSingle'
        set_hl(desc_hl_group, i - 1, sep_start + 2, i, 0)
    end

    return buf_id
end

H.buffer_get_width = function()
    if not H.is_valid_buf(H.state.buf_id) then return end
    local lines = vim.api.nvim_buf_get_lines(H.state.buf_id, 0, -1, false)
    local res = 0
    for _, l in ipairs(lines) do
        res = math.max(res, vim.fn.strdisplaywidth(l))
    end
    return res
end

-- Clues ----------------------------------------------------------------------
H.clues_get_all = function(mode)
    local res = {}

    -- Order of clue precedence: config clues < buffer mappings < global mappings
    local config_clues = H.clues_normalize(H.get_config().clues) or {}
    local mode_clues = vim.tbl_filter(function(x) return x.mode == mode end, config_clues)
    for _, clue in ipairs(mode_clues) do
        local lhsraw = H.replace_termcodes(clue.keys)

        local res_data = res[lhsraw] or {}

        -- - Allow callable clue description
        local desc = H.expand_callable(clue.desc)
        -- - Fall back to possibly already present fields to allow partial
        --   overwrite in later clues. Like to add `postkeys` and inherit `desc`.
        res_data.desc = desc or res_data.desc
        res_data.postkeys = H.replace_termcodes(clue.postkeys) or res_data.postkeys

        res[lhsraw] = res_data
    end

    for _, map_data in ipairs(vim.api.nvim_get_keymap(mode)) do
        local lhsraw = H.replace_termcodes(map_data.lhs)
        local res_data = res[lhsraw] or {}
        res_data.desc = map_data.desc or ''
        res[lhsraw] = res_data
    end

    for _, map_data in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
        local lhsraw = H.replace_termcodes(map_data.lhs)
        local res_data = res[lhsraw] or {}
        res_data.desc = map_data.desc or ''
        res[lhsraw] = res_data
    end

    return res
end

H.clues_normalize = function(clues)
    local res = {}
    local process
    process = function(x)
        x = H.expand_callable(x)
        if H.is_clue(x) then return table.insert(res, x) end
        if not H.islist(x) then return nil end
        for _, y in ipairs(x) do
            process(y)
        end
    end

    process(clues)
    return res
end

H.clues_filter = function(clues, query)
    local keys = H.query_to_keys(query)
    for clue_keys, _ in pairs(clues) do
        if not vim.startswith(clue_keys, keys) then clues[clue_keys] = nil end
    end
    return clues
end

H.clues_to_buffer_content = function(clues, keys)
    --g Use translated keys to properly handle cases like `<Del>`, `<End>`, etc.
    keys = H.keytrans(keys)

    -- Gather clue data
    local keys_len = keys:len()
    local keys_pattern = string.format('^%s(.+)$', vim.pesc(keys))

    local next_key_data, next_key_max_width = {}, 0
    for clue_keys, clue_data in pairs(clues) do
        local left, _, rest_keys = H.keytrans(clue_keys):find(keys_pattern)

        -- Add non-trivial next key data only if clue matches current keys plus
        -- something more
        if left ~= nil then
            local next_key = H.clues_get_first_key(rest_keys)

            -- Update description data
            local data = next_key_data[next_key] or {}
            data.n_choices = (data.n_choices or 0) + 1

            -- - Add description directly if it is group clue with description or
            --   a non-group clue
            if next_key == rest_keys then
                data.desc = clue_data.desc or ''
                data.has_postkeys = clue_data.postkeys ~= nil
            end

            next_key_data[next_key] = data

            -- Update width data
            local next_key_width = vim.fn.strchars(next_key)
            data.next_key_width = next_key_width
            next_key_max_width = math.max(next_key_max_width, next_key_width)
        end
    end

    -- Convert to array sorted by keys and finalize content
    local next_keys_extra = vim.tbl_map(
        function(x) return { key = x, keytype = H.clues_get_next_key_type(x) } end,
        vim.tbl_keys(next_key_data)
    )
    table.sort(next_keys_extra, H.clues_compare_next_key)
    local next_keys = vim.tbl_map(function(x) return x.key end, next_keys_extra)

    local res = {}
    for _, key in ipairs(next_keys) do
        local data = next_key_data[key]
        local is_group = data.n_choices > 1
        local desc = data.desc or string.format('+%d choice%s', data.n_choices, is_group and 's' or '')
        local next_key = key .. string.rep(' ', next_key_max_width - data.next_key_width)
        table.insert(res, { next_key = next_key, desc = desc, is_group = is_group, has_postkeys = data.has_postkeys })
    end

    return res
end

H.clues_get_first_key = function(keys)
    -- `keys` are assumed to be translated
    -- Special keys
    local special = keys:match('^(%b<>)')
    if special ~= nil then return special end

    -- <
    if keys:find('^<') ~= nil then return '<' end

    -- Other characters
    return vim.fn.strcharpart(keys, 0, 1)
end

H.clues_get_next_key_type = function(x)
    if x:find('^%w$') ~= nil then return 'alphanum' end
    if x:find('^<.*>$') ~= nil then return 'mod' end
    return 'other'
end

H.clues_compare_next_key = function(a, b)
    local a_type, b_type = a.keytype, b.keytype
    if a_type == b_type then
        local cmp = vim.stricmp(a.key, b.key)
        return cmp == -1 or (cmp == 0 and a.key < b.key)
    end

    if a_type == 'alphanum' then return true end
    if b_type == 'alphanum' then return false end

    if a_type == 'mod' then return true end
    if b_type == 'mod' then return false end
end

-- Clue generators ------------------------------------------------------------
H.make_clues_with_register_contents = function(mode, prefix)
    local make_register_desc = function(register)
        return function()
            local ok, value = pcall(vim.fn.getreg, register, 1)
            if not ok or value == '' then return nil end
            return vim.inspect(value)
        end
    end

    local all_registers = vim.split('0123456789abcdefghijklmnopqrstuvwxyz*+"-:.%/#', '')

    local res = {}
    for _, register in ipairs(all_registers) do
        table.insert(res, { mode = mode, keys = prefix .. register, desc = make_register_desc(register) })
    end
    table.insert(res, { mode = mode, keys = prefix .. '=', desc = 'Result of expression' })

    return res
end

-- Predicates -----------------------------------------------------------------
H.is_trigger = function(x) return type(x) == 'table' and type(x.mode) == 'string' and type(x.keys) == 'string' end

H.is_clue = function(x)
    if type(x) ~= 'table' then return false end
    local mandatory = type(x.mode) == 'string' and type(x.keys) == 'string'
    local extra = (x.desc == nil or type(x.desc) == 'string' or vim.is_callable(x.desc))
        and (x.postkeys == nil or type(x.postkeys) == 'string')
    return mandatory and extra
end

H.is_array_of = function(x, predicate)
    if not H.islist(x) then return false end
    for _, v in ipairs(x) do
        if not predicate(v) then return false end
    end
    return true
end

-- Utilities ------------------------------------------------------------------
H.error = function(msg) error(string.format('(nopain) %s', msg), 0) end

H.map = function(mode, lhs, rhs, opts)
    if lhs == '' then return end
    opts = vim.tbl_deep_extend('force', { silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

H.replace_termcodes = function(x)
    if x == nil then return nil end
    -- Use `keytrans` prior replacing termcodes to work correctly on already
    -- replaced variant of `<F*>` keys
    return vim.api.nvim_replace_termcodes(H.keytrans(x), true, true, true)
end

H.keytrans = function(x)
    local res = vim.fn.keytrans(x):gsub('<lt>', '<')
    return res
end

H.get_forced_submode = function()
    local mode = vim.fn.mode(1)
    if not mode:sub(1, 2) == 'no' then return '' end
    return mode:sub(3)
end

H.get_default_register = function()
    local clipboard = vim.o.clipboard
    if clipboard:find('unnamedplus') ~= nil then return '+' end
    if clipboard:find('unnamed') ~= nil then return '*' end
    return '"'
end

H.is_valid_buf = function(buf_id) return type(buf_id) == 'number' and vim.api.nvim_buf_is_valid(buf_id) end

H.is_valid_win = function(win_id) return type(win_id) == 'number' and vim.api.nvim_win_is_valid(win_id) end

H.expand_callable = function(x, ...)
    if vim.is_callable(x) then return x(...) end
    return x
end

H.redraw_scheduled = vim.schedule_wrap(function() vim.cmd('redraw') end)

H.getcharstr = function()
    -- Ensure redraws still happen
    H.timers.getcharstr:start(0, 50, H.redraw_scheduled)
    local ok, char = pcall(vim.fn.getcharstr)
    H.timers.getcharstr:stop()
    -- Terminate if couldn't get input (like with <C-c>) or it is `<Esc>`
    if not ok or char == '\27' or char == '' then return end
    return H.get_langmap()[char] or char
end

H.get_langmap = function()
    if vim.o.langmap == '' then return {} end

    -- Get langmap parts by splitting at "," not preceded by "\"
    local langmap_parts = vim.fn.split(vim.o.langmap, '[^\\\\]\\zs,')

    -- Process each langmap part
    local res = {}
    for _, part in ipairs(langmap_parts) do
        H.process_langmap_part(res, part)
    end
    return res
end

H.process_langmap_part = function(res, part)
    local semicolon_byte_ind = vim.fn.match(part, '[^\\\\]\\zs;') + 1

    -- Part is without ';', like 'aAbB'
    if semicolon_byte_ind == 0 then
        -- Drop backslash escapes
        part = part:gsub('\\([^\\])', '%1')

        for i = 1, vim.fn.strchars(part), 2 do
            -- `strcharpart()` has 0-based indexes
            local from, to = vim.fn.strcharpart(part, i - 1, 1), vim.fn.strcharpart(part, i, 1)
            if from ~= '' and to ~= '' then res[from] = to end
        end

        return
    end

    -- Part is with ';', like 'ab;AB'
    -- - Drop backslash escape
    local left = part:sub(1, semicolon_byte_ind - 1):gsub('\\([^\\])', '%1')
    local right = part:sub(semicolon_byte_ind + 1):gsub('\\([^\\])', '%1')

    for i = 1, vim.fn.strchars(left) do
        local from, to = vim.fn.strcharpart(left, i - 1, 1), vim.fn.strcharpart(right, i - 1, 1)
        if from ~= '' and to ~= '' then res[from] = to end
    end
end

H.list_concat = function(...)
    local res = {}
    for i = 1, select('#', ...) do
        for _, x in ipairs(select(i, ...) or {}) do
            table.insert(res, x)
        end
    end
    return res
end

-- TODO: Remove after compatibility with Neovim=0.9 is dropped
H.islist = vim.fn.has('nvim-0.10') == 1 and vim.islist or vim.tbl_islist

return NoPain

