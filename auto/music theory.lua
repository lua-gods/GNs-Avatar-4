
local UUID = "943218fd-5bbc-4015-bf7f-9da4f37bac59" --"b0e11a12-eada-4f28-bb70-eb8903219fe5"

local NOTES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }
---@param pitch number
---@return string?
local function getNoteName(pitch) -- Stolen from 4P5, thankyou 4P5
	local note = NOTES[pitch % 12 + 1]
	local octave = math.floor((pitch / 12) - 1)
	if pitch >= 21 and pitch <= 95 then -- A0 to B7
		return note .. octave
	else
		return getNoteName(pitch + (pitch < 21 and 12 or -12))
	end
end

local pos = vec(920, 66, 1664)

local pianoID = tostring(pos)

---@type ChloePianoAPI
local pianoAPI = world.avatarVars()[UUID]



-- Guitar standard tuning (MIDI numbers): E2 A2 D3 G3 B3 E4
local standard_tuning = {40, 45, 50, 55, 59, 64}

local note_names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}

-- Convert MIDI number to note name (e.g. 60 -> C4)
local function midi_to_note_name(midi)
		local index = (midi % 12) + 1
		local octave = math.floor(midi / 12) - 1
		return note_names[index] .. tostring(octave)
	end

-- Convert a guitar chord voicing to piano note names
-- Input: table of 6 fret numbers, -1 means muted string
function chord_voicing_to_notes(voicing)
	local standard_tuning = {40, 45, 50, 55, 59, 64}
	local note_names = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}

	local notes = {}
	for i = 1, 6 do
		local fret = voicing[i]

		if fret ~= nil and fret ~= -1 and fret ~= "x" and fret ~= "X" then
			local midi = standard_tuning[i] + fret
			table.insert(notes, midi_to_note_name(midi))
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

local function play(chord)
	local notes = chord_voicing_to_notes(chord)

	for i, note in ipairs(notes) do
		pianoAPI.playNote(pianoID,note,true)
	end
end

local track = seq.new()

local function trackAdd(chord)
	local o = track.keyframes[#track.keyframes] and track.keyframes[#track.keyframes].time + 0.5 * 16 or 0
	track:add(o+0,function () play(chord) end)

	track:add(o+1*16,function () play(chord) end)
	track:add(o+1.5*16,function () play(chord) end)
	
	track:add(o+2.5*16,function () play(chord) end)
	track:add(o+3*16,function () play(chord) end)
	track:add(o+3.5*16,function () play(chord) end)
	track:add(o+4*16,function () play(chord) end)
	
	track:add(o+5*16,function () play(chord) end)
	track:add(o+5.5*16,function () play(chord) end)
	
	track:add(o+6.5*16,function () play(chord) end)
	track:add(o+7*16,function () play(chord) end)
	track:add(o+7.5*16,function () play(chord) end)
end

local function trackAdd2(chord)
	local o = track.keyframes[#track.keyframes] and track.keyframes[#track.keyframes].time + 4 * 10 or 0
	for i = 1, 80, 8 do
		track:add(o+i,function () play(chord) end)
	end
end

if true then
	for i = 1, 4, 1 do
		trackAdd(major[3])
		trackAdd(major[6])
		trackAdd(major[8])
		trackAdd(minor[8])
	end
end

--trackAdd2(major[8])
--trackAdd2(major[12])
--trackAdd2(major[1])
--trackAdd2(minor[1])


track:start(events.TICK)



track:start(events.TICK)

events.TICK:register(function ()
	local t = math.abs((math.floor(client:getSystemTime()/50) % 100) - 50) + 21
	--pianoAPI.playNote(pianoID,getNoteName(t),true)
end)
