local i = 0

return function (array, callback, finishCallback)
	i = i + 1
	local last = nil
	local part = models:newPart(i,"WORLD")
	part.midRender = function ()
		local n,data = next(array,last)
		if n then
			last = n
			callback(data)
		else
			finishCallback()
			part:remove()
		end
	end
end
