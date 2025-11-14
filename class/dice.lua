local dice = {}


local cachedAccumulative = {}
local cachedTotal = {}



---Returns the index of the chosen one out of all the weights.  
---Weights being how biased the random is towards that given index.
---***
---Example:  
---```lua
---local index = dice.randomWeight({1, 1, 10})
---print(index)
---```
---the output is more than likely to return `3` because the 3rd value is 10x more likely to be chosen.
---***
---advanced notes:  
---- caches the table used to get the weight  
---- uses binary search to get the index  
---@param weights number[]
---@return integer
function dice.randomWeightIndex(weights)
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

local cachedLabeledWeights = {}
---@param labeledWeights {[1]:number,[2]:any}[]
function dice.randomWeight(labeledWeights)
	
	
	local weights = {}
	local names = {}
	
	if cachedLabeledWeights[labeledWeights] then
		weights,names = table.unpack(cachedLabeledWeights[labeledWeights])
	else
		for i, value in ipairs(labeledWeights) do
			weights[i] = value[1]
			names[i] = value[2]
		end
		cachedLabeledWeights[labeledWeights] = {weights,names}
	end
	
	local index = dice.randomWeightIndex(weights)
	
	if names[index] then
		return names[index]
	end
end


---Returns a random number between `from` and `to`.  
---The difference between this and `math.random(from,to)` is that this returns a float.
---@param from number
---@param to number
---@return number
function dice.randomRange(from,to)
	return math.random() * (to - from) + from
end

_G.dice = dice
return dice