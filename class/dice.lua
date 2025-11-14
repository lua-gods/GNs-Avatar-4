local dice = {}


local cachedAccumulative = {}
local cachedTotal = {}
function dice.weightedRandom(weights)
	-- mak a cumulative
	local cumulative
	local total = 0
	if cachedAccumulative[weights] then
		cumulative = cachedAccumulative[weights]
		total = cachedTotal[weights]
	else
		cumulative = {}
		for i, w in ipairs(weights) do
			total = total + w
			cumulative[i] = total
		end
		cachedAccumulative[weights] = cumulative
		cachedTotal[weights] = total
	end
	
	local r = math.random() * total
	-- binary search
	local left = 1
	local right = #weights
	while left < right do
		local mid = math.floor((left + right) / 2)
		if r > cumulative[mid] then
			left = mid + 1
		else
			right = mid
		end
	end
	
	return left
end

_G.dice = dice
return dice