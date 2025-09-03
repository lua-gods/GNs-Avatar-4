---@class utils.string
local utilString = {}

function utilString.split(string,separator)
	local t = {}
	for str in string.gmatch(string, "([^" .. separator .. "]+)") do
		table.insert(t, str)
	end
	return t
end


function utilString.separateLines(str)
	local lines = {}
	-- capture everything up to \n (including empty)
	for line in str:gmatch("([^\n]*)\n?") do
		if line ~= "" or #lines > 0 then
			-- avoid adding an extra empty string at the end
			table.insert(lines, line)
		end
	end
	return lines
end


return utilString