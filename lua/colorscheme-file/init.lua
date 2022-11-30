local uv = vim.loop

local opts = {
	path = vim.fn.stdpath('data') .. '/colorscheme-file',
	silent = false,
	aliases = {},
}

local M = {}

local notify = function(str, level)
	if opts.silent then return end
	if not level then level = vim.log.levels.ERROR end

	vim.notify(str, level, { title = 'colorscheme-file' })
end

local set_colorscheme = function(colorscheme)
	if colorscheme ~= vim.g.colors_name then
		vim.cmd.colorscheme(colorscheme)
	end
end

local read_file = function(fd)
	local stat = uv.fs_fstat(fd)
	if not stat then
		notify(string.format('Could not stat file: %s', opts.path))
		return false
	end

	local data = uv.fs_read(fd, stat.size)
	if not data then
		notify(string.format('Could not read file: %s', opts.path))
		return false
	end

	return data
end

local set_fallback = function(colors_available)
	if opts.fallback and vim.tbl_contains(colors_available, opts.fallback) then
		set_colorscheme(opts.fallback)
		return true
	end

	return false
end

M.set_colorscheme = function()
	local colors_available = vim.fn.getcompletion('', 'color')

	local fd = uv.fs_open(opts.path, 'r', 0)
	if not fd then
		notify(string.format('Could not open file: %s', opts.path))
		return set_fallback(colors_available)
	end

	local data = read_file(fd)
	uv.fs_close(fd)
	if not data then
		return set_fallback(colors_available)
	end

	local colorscheme = data:gsub('[\n\r]', '')
	local alias = opts.aliases[colorscheme]
	if alias then colorscheme = alias end

	if vim.tbl_contains(colors_available, colorscheme) then
		set_colorscheme(colorscheme)
	else
		notify(string.format('Colorscheme does not exist: %s', colorscheme))
		return set_fallback(colors_available)
	end

	return true
end

local fe

M.watch = function()
	if fe then return end

	local _, name
	fe, _, name = uv.new_fs_event()
	if not fe then
		notify(string.format('Could not initialize fs_event watcher: %s', name))
		return false
	end

	fe:start(opts.path, {}, function(err, filename, events)
		if err then
			notify(string.format('Error watching %s: %s', filename, err))
			return
		elseif events.rename then
			fe:stop()
			fe = nil
			return
		end
		vim.schedule(M.set_colorscheme)
	end)

	return true
end

M.stop_watching = function()
	if fe then
		fe:stop()
		fe = nil
	else
		notify('No watcher active!', vim.log.levels.WARN)
	end
end

M.set_opts = function(o)
	opts = vim.tbl_extend('force', opts, o)
end

M.setup = function(o)
	if o then M.set_opts(o) end

	M.set_colorscheme()
	M.watch()
end

return M
