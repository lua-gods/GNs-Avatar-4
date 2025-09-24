if true then return end
local env = {
	yap = function ()
		print("yapper")
	end
}
local test = (","..([[

text:5,octagon:[9],test

]])..","):gsub("\n","")
:gsub("([^,:%[%]%(%)%{%}]+)",function (str)
	return (tonumber(str) and str or '"'..str..'"')
end)
:gsub("(,[^:,]+),",function (str)
	return str..":[],"
end)
print(test)

-- hat height:5,

