

function ChordVoicingToNotes(voicing)
	local tuning = {40, 45, 50, 55, 59, 64} -- Magic numbers I DONT UNDERSTAND

	local notes = {}
	for i = 1, 6 do
		local fret = voicing[i]

		if fret ~= nil and fret ~= -1 and fret ~= "x" and fret ~= "X" then
			local midi = tuning[i] + fret
			table.insert(notes, midi)
		end
	end
	return notes
end


local major = {
	[1]={-1, 3, 2, 0, 1, 0},     -- X32010      C
	[2]={x=1, 4, 6, 6, 6, 4}, -- barre          C#
	[3]={-1, -1, 0, 2, 3, 2},    -- XX0232      D
	[4]={x=1, 6, 8, 8, 8, 6}, -- barre          D#
	[5]={0, 2, 2, 1, 0, 0},      -- 022100      E
	[6]={1, 3, 3, 2, 1, 1},      -- 133211      F
	[7]={2, 4, 4, 3, 2, 2},  -- 244322          F#
	[8]={3, 2, 0, 0, 0, 3},      -- 320003      G
	[9]={4, 6, 6, 5, 4, 4},  -- 466544          G#
	[10]={-1, 0, 2, 2, 2, 0},     -- X02220     A
	[11]={x=1, 1, 3, 3, 3, 1},-- barre          A#
	[12]={x=1, 2, 4, 4, 4, 2}     -- barre      B
}

local minor = {
	[1]={"x", 3, 5, 5, 4, 3},  --      barre   Cm
	[2]={"x", 4, 6, 6, 5, 4}, --       barre   C#m
	[3]={"x", "x", 0, 2, 3, 1}, --      open   Dm
	[4]={"x", 6, 8, 8, 7, 6}, --       barre   D#m
	[5]={0, 2, 2, 0, 0, 0},     --      open   Em
	[6]={1, 3, 3, 1, 1, 1},     --     barre   Fm
	[7]={2, 4, 4, 2, 2, 2}, --         barre   F#m
	[8]={3, 5, 5, 3, 3, 3}, --         barre   Gm
	[9]={4, 6, 6, 4, 4, 4}, --         barre   G#m
	[10]={"x", 0, 2, 2, 1, 0},  --      open   Am
	[11]={"x", 1, 3, 3, 2, 1}, --      barre   A#m
	[12]={"x", 2, 4, 4, 3, 2}   --     barre   Bm
}

local seq = require("lib.sequence")

local sound = {
	git1 = 36, -- C2
	git2 = 41,  -- F2
	git3 = 48, -- C3
	git4 = 53, -- F3
	git5 = 60, -- C4
	git6 = 65,-- F4
	git7 = 72  -- C5
}
local function getAudio(midi)
	local closestDist = math.huge
	local closestMidi
	local closestSound
	for key, value in pairs(sound) do
		local diff = math.abs(midi - value)
		if diff < closestDist then
			closestMidi = value
			closestDist = diff
			closestSound = key
		end
	end
	return closestSound,closestMidi
end

local seq = require("lib.sequence")

local OCTAVE_SHIFT = 0


local function play(chord)
	local notes = ChordVoicingToNotes(chord)

	local playingAudio = {}
	if player:isLoaded() then
		for i, midi in ipairs(notes) do
			local audio,offset = getAudio(midi)
			playingAudio[i] = sounds[audio]:pos(player:getPos()):pitch(2^(((midi-offset)) / 12+OCTAVE_SHIFT)):play()
		end
		animations.player.guitarIdle:stop()
		animations.player.guitarStrum:stop():play()
	end
	return playingAudio
end



local track = seq.new()

--	local function trackAdd(chord)
--		local o = track.keyframes[#track.keyframes] and track.keyframes[#track.keyframes].time + 0.5 * 16 or 0
--		track:add(o+0,function () play(chord) end)
--	
--		track:add(o+1*16,function () play(chord) end)
--		track:add(o+1.5*16,function () play(chord) end)
--		
--		track:add(o+2.5*16,function () play(chord) end)
--		track:add(o+3*16,function () play(chord) end)
--		track:add(o+3.5*16,function () play(chord) end)
--		track:add(o+4*16,function () play(chord) end)
--		
--		track:add(o+5*16,function () play(chord) end)
--		track:add(o+5.5*16,function () play(chord) end)
--		
--		track:add(o+6.5*16,function () play(chord) end)
--		track:add(o+7*16,function () play(chord) end)
--		track:add(o+7.5*16,function () play(chord) end)
--	end

local function trackAdd2(chord)
	local o = track.keyframes[#track.keyframes] and track.keyframes[#track.keyframes].time + 5 * 20 or 0
	track:add(o,function () play(chord) end)
end

--	if false then
--		for i = 1, 4, 1 do
--			trackAdd(major[3])
--			trackAdd(major[6])
--			trackAdd(major[8])
--			trackAdd(minor[8])
--		end
--	end

if false then
	trackAdd2(major[8])
	trackAdd2(major[12])
	trackAdd2(major[1])
	trackAdd2(minor[1])
end



local shade = 0.5

models.player.Gitar.Shade:setColor(shade,shade,shade)

--track:start(events.TICK)



local keymappingPitchOffset = 35

local keymapping = {
	"a", -- C2
		"w",
	"s",
		"e",
	"d",
	"f",
		"t",
	"g",
		"y",
	"h",
		"u",
	"j",
}

local keyNames = {
	"C",
	"C#",
	"D",
	"D#",
	"E",
	"F",
	"F#",
	"G",
	"G#",
	"A",
	"A#",
	"B",
}

local keybindings = {}

local playingNotes = {}

local shift = keybinds:newKeybind("shit","key.keyboard.left.shift")

for key, value in pairs(keymapping) do
	local binding = keybinds:newKeybind("Chord "..value, "key.keyboard."..value,true)
	keybindings[key] = binding
end

local Tween = require("lib.tween")

function pings.play(minorOrMajor,i)
	playingNotes[i] = play(minorOrMajor and minor[i] or major[i])
end

local Macro = require("lib.macros")

local book

if host:isHost() then
	book = require("auto.screen")
end


local GUITAR = Macro.new(function (events, screen)
	if host:isHost() then
		
		local GNUI = require("lib.GNUI.main")
		local Button = require("lib.GNUI.element.button")
		
		pings.guitarToggle(true)
		local x = 0
		
		local buttons = {}
		local Piano = GNUI.newBox()
		screen
		:addChild(Piano)
		Piano
		:setAnchor(0.5,0.5)
		:setDimensions(-100,40,100,100)
		
		local function makeMajor()
			local btn = Button.new()
			:setAnchor(0,0,0,1)
			:setPos(x,0)
			:setSize(16,0)
			:setFontScale(1)
			:setTextAlign(0.5,0.95)
			x = x + 16
			Piano:addChild(btn)
			buttons[#buttons+1] = btn
		end
		
		local function makeMinor()
			local btn = Button.new()
			:setAnchor(0,0,0,0.6)
			:setPos(x-5-16,0)
			:setSize(10,0)
			:setColor(0.2,0.2,0.2)
			:setDefaultTextColor("white")
			:setFontScale(0.5)
			:setTextAlign(0.5,0.9)
			Piano:addChild(btn)
			table.insert(buttons,#buttons,btn)
		end
		
		makeMajor()
		makeMajor()
		makeMinor()
		makeMajor()
		makeMinor()
		makeMajor()
		makeMajor()
		makeMinor()
		makeMajor()
		makeMinor()
		makeMajor()
		makeMinor()
		
		
		---@param binding Keybind
		for key, binding in pairs(keybindings) do
			buttons[key]:setText("["..keyNames[key].."]\n"..keymapping[key])
			binding.press = function ()
				if models.player.Gitar:getVisible() then
					pings.play(shift:isPressed(),key)
					buttons[key]:press()
					return true
				end
			end
			binding.release = function ()
				if playingNotes[key] then
					
					---@param value Sound
					for key, value in pairs(playingNotes[key]) do
						Tween.tweenFunction(1,0,2,"outQuad",function (t)
							value:setVolume(t)
						end,function() 
							value:stop()
						end)
					end
				end
				buttons[key]:release()
			end
		end
	end
	animations.player.guitarIdle:play()
	models.player.Gitar:setVisible(true)
	
	events.ON_EXIT:register(function ()
		models.player.Gitar:setVisible(false)
		animations.player.guitarIdle:stop()
		animations.player.guitarStrum:stop()
		if host:isHost() then
		pings.guitarToggle(false)
	end
	end)
end)

function pings.guitarToggle(toggle)
	if not host:isHost() then
		GUITAR:setActive(toggle)
	end
end

models.player.Gitar:setVisible(false)

if host:isHost() then
	book:newPage("Guitar",GUITAR)
	--renderer:setCameraPos(-0.5,-0.5,-2)
end