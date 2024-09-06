-- vim.api.nvim_create_user_command('FormatDisable', function(args)
-- 	if args.bang then
-- 		-- FormatDisable! will disable formatting just for this buffer
-- 		vim.b.disable_autoformat = true
-- 	else
-- 		vim.g.disable_autoformat = true
-- 	end
-- end, {
-- 	desc = 'Disable autoformat-on-save',
-- 	bang = true,
-- })
--
-- vim.api.nvim_create_user_command('FormatEnable', function()
-- 	vim.b.disable_autoformat = false
-- 	vim.g.disable_autoformat = false
-- end, {
-- 	desc = 'Re-enable autoformat-on-save',
-- })

vim.api.nvim_create_user_command('AutoFormatToggle', function(args)
    local bufnr = vim.api.nvim_get_current_buf()

    -- Initialize the buffer variable with the global if it doesn't exist. Default to false.
    if vim.b[bufnr].disable_autoformat == nil then
        vim.b[bufnr].disable_autoformat = vim.g.disable_autoformat or false
    end

    if args.bang then
        -- Toggle formatting for this buffer
        vim.b[bufnr].disable_autoformat = not vim.b[bufnr].disable_autoformat
    else
        -- Toggle global formatting
        vim.g.disable_autoformat = not vim.g.disable_autoformat
    end

    -- Print the current state
    if args.bang then
        print('Buffer autoformatting ' .. (vim.b[bufnr].disable_autoformat and 'disabled' or 'enabled'))
    else
        print('Global autoformatting ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'))
    end
end, {
    desc = 'Toggle autoformat-on-save',
    bang = true,
})
