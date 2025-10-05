--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Note Block Studio file reader/player
/ /_/ / /|  /  desc: allows avatars to load and play .NBS files in their avatar
\____/_/ |_/ source: https://github.com/lua-gods/GNs-Avatar-4/blob/main/lib/nbs.lua ]]

local hasEvents,Events = pcall(require,"./event")

--[────────-< CONFIG >-────────]--
local MAX_NOTES_PER_TICK=64
-- the maximum amount of notes that can play at the same time

local PROCESS_MODE=1
-- 0: MODEL RENDER, plays when the player is loaded, runs on RENDER, works on lower permission levels
-- 1: WORLD RENDER, plays when the avatar is loaded, run on WORLD_RENDER, requires higher permission levels
---2: SKULL RENDER, plays when the player head is loaded, runs on RENDER, works on lower permission levels

--────────-< How to install >-────────]

--- in the avatar.json, add a new entry called "resources" with an array, and add "*.nbs" to the array.
--- this tells figura to load alongside the avatar all the .nbs files in the avatar folder.

--- or if you dont know what that means
---in the avatar.json, copy the resources line down here into your avatar.json
--[[@@@
{
	...
	"resources": ["*.nbs"],
	...
}
]]



---A Music track loaded from a .NBS file
---@class NBS.Track
---@field name string
---@field instrumentCount integer
---@field layerCount integer
---@field songName string
---@field songAuthor string
---@field songOriginalAuthor string
---@field songDescription string
---@field songTempo integer
---@field songLength integer
---@field timeSignature integer
---@field loop boolean
---@field loopStartTick integer
---@field maxLoopCount integer
---@field notes NBS.Noteblock[]
---@field loudest number

local Nbs={}

---A representation of a noteblock in Note Block Studio's format
---@class NBS.Noteblock
---@field tick integer
---@field instrument integer
---@field key integer
---@field volume integer
---@field pitch integer


--[────────────────────────-< Instruments >-────────────────────────]--
-- these can be replaced with custom sound IDs.
-- any entries starting with a dot . will get replaced by minecraft:block.note_block.
---@type table<integer,Minecraft.soundID>
local instruments={
	[0] =".harp",
	[1] =".bass",
	[2] =".basedrum",
	[3] =".snare",
	[4] =".hat",
	[5] =".guitar",
	[6] =".flute",
	[7] =".bell",
	[8] =".chime",
	[9] =".bell",
	[10]=".iron_xylophone",
	[11]=".cow_bell",
	[12]=".didgeridoo",
	[13]=".bit",
	[14]=".banjo",
	[15]=".pling",
}

-- prefix inserter
for i, v in pairs(instruments) do
	if v:find("^%.") then
		instruments[i]="minecraft:block.note_block"..v
	end
end

---@param instrument Minecraft.soundID
---@param pos Vector3
---@param pitch integer
---@param volume integer
---@param attenuation integer
local function defaultPlay(instrument,pos,pitch,volume,attenuation)
	sounds[instrument]
	:pos(pos)
	:pitch(pitch)
	:attenuation(attenuation)
	:volume(volume)
	:play()
end

---@type table<NBS.MusicPlayer, NBS.MusicPlayer>
local activeMusicPlayers={} -- holds the active playing one to loop ver them

local lastTime=client:getSystemTime()

local function process()
	local time=client:getSystemTime()
	local delta=(time-lastTime) / 1000
	lastTime=time
	if delta > 1 then delta = 1 end
	
	---@param mp NBS.MusicPlayer
	for _, mp in pairs(activeMusicPlayers) do
		
		mp.tick=mp.tick+delta * (mp.songTempo or mp.track.songTempo) * mp.speed
		for i=1, MAX_NOTES_PER_TICK, 1 do
			local cnote=mp.track.notes[mp.currentNote]
			if cnote then
				if math.sign(mp.tick-cnote.tick) - math.sign(mp.speed) == 0 then
					mp.currentNoteTick=cnote.tick
					mp.currentNote=mp.currentNote+math.sign(mp.tick-cnote.tick)
					if mp.loopCount == 0 or mp.track.loopStartTick <= cnote.tick then
						local pitch=2^(((cnote.key-9)/12+mp.transposition)-3)
						if instruments[cnote.instrument] then
							if cnote.volume > 0.01 then
							mp.playNote(instruments[cnote.instrument],mp.pos,pitch,cnote.volume*mp.volume,mp.attenuation)
							end
							if hasEvents then
								mp.NOTE_PLAYED:invoke(cnote)
							end
						end
					end
				else
					break
				end
			end
		end
		if mp.track.loop then
			if mp.speed > 0 then
				
				if mp.tick >= mp.track.songLength+1 then
					mp.tick=mp.tick-mp.track.songLength-1+mp.track.loopStartTick
					if mp.loopCount >= mp.track.maxLoopCount then 
						mp:stop()
						if mp.TRACK_FINISHED then
							mp.TRACK_FINISHED:invoke()
						end
					end
					mp.currentNote=1
					mp.loopCount=mp.loopCount+1
				end
			else
				if mp.tick < mp.track.loopStartTick then
					mp.tick=mp.track.songLength+1
					mp.currentNote=#mp.track.notes
					if mp.loopCount >= mp.track.maxLoopCount then
						mp:stop()
						if mp.TRACK_FINISHED then
							mp.TRACK_FINISHED:invoke()
						end
					end
					mp.loopCount=mp.loopCount+1
				end
			end
		else
			if mp.tick >= mp.track.songLength+1 then
				mp:stop()
				if mp.TRACK_FINISHED then
					mp.TRACK_FINISHED:invoke()
				end
			end
		end
	end
end


if PROCESS_MODE == 0 then
	models:newPart("MusicProcessor").midRender = process
elseif PROCESS_MODE == 1 then
	events.WORLD_RENDER:register(process)
elseif	PROCESS_MODE == 2 then
	local first = false
	events.WORLD_RENDER:register(function (delta) first=true end)
	events.SKULL_RENDER:register(function ()
		if first then
			process()
			first = false
		end
	end)
end


---@class NBS.MusicPlayer
---@field speed number
---@field volume number
---@field transposition number
---@field attenuation number
---@field NOTE_PLAYED Event
---@field TRACK_FINISHED Event
---@field track NBS.Track
---@field tick integer
---@field currentNoteTick integer
---@field pos Vector3
---@field currentNote integer
---@field isPlaying boolean
local MusicPlayer={}
MusicPlayer.__index=MusicPlayer



---Creates a new music player
---@param track NBS.Track?
---@return NBS.MusicPlayer
function Nbs.newMusicPlayer(track)
	local new={
		track=track,
		tick=0,
		currentNoteTick=0,
		speed=1,
		volume=1,
		attenuation=1,
		pos=vec(0,-10000,0),
		transposition=0,
		loopCount=0,
		isPlaying=false,
		currentNote=1,
		NOTE_PLAYED = hasEvents and (Events.new()) or nil,
		TRACK_FINISHED = hasEvents and (Events.new()) or nil,
		playNote = defaultPlay
	}
	return setmetatable(new,MusicPlayer)
end


---Plays the song / Continues where it stops.
---@param reset boolean?
---@return NBS.MusicPlayer
function MusicPlayer:play(reset)
	if reset then self:stop() end
	activeMusicPlayers[self]=self
	self.isPlaying=true
	return self
end


---Stops the playback of the song, resetting the playback time.
---@return NBS.MusicPlayer
function MusicPlayer:stop()
	activeMusicPlayers[self]=nil
	self.isPlaying=false
	self.loopCount=0
	self.currentNote=1
	self.tick=-2
	return self
end

---Sets the function that is called when a note is to be played.
---@param callback fun(instrument: Minecraft.soundID, pos: Vector3, pitch: number, volume: number, attenuation: number)
function MusicPlayer:setPlayCallback(callback)
	self.playNote = callback or defaultPlay
end


---Stops the playback of the song, without resetting the playback time.
---@return NBS.MusicPlayer
function MusicPlayer:pause()
	activeMusicPlayers[self]=nil
	self.isPlaying=false
	return self
end

---Sets the playback speed.
---@param speed number?
---@return NBS.MusicPlayer
function MusicPlayer:setSpeed(speed)
	self.speed = speed or 1
	return self
end

---Sets the tempo the songs played will use. leaving it nil will use the song's default tempo.  
---NOTE: the tempo is in ticks per second. not Beats per Minute
---@param tempo number
---@return NBS.MusicPlayer
function MusicPlayer:setTempoOverride(tempo)
	self.songTempo = tempo
	return self
end

---Sets the octave transposition of the song.
---@param shift integer
---@return NBS.MusicPlayer
function MusicPlayer:setOctaveShift(shift)
	self.transposition = shift
	return self
end


---@overload fun(self: NBS.MusicPlayer,xyz: Vector3): NBS.MusicPlayer
---@param x number
---@param y number
---@param z number
---@return NBS.MusicPlayer
function MusicPlayer:setPos(x,y,z)
	local tx,ty,tz=type(x), type(y), type(z)
	local pos
	if (tx == "number" and ty == "number" and tz == "number") then
		pos = vec(x,y,z)
	elseif (tx == "Vector3" and ty == "nil" and tz == "nil") then
		---@cast tx Vector3
		pos = x
	else
		error(("Invalid Vector3 parameter, expected (number, number, number), (Vector3), instead got (%s, %s, %s)"):format(tx,ty,tz),2)
	end
	self.pos=pos
	return self
end


---Sets the track to be played.
---@param track NBS.Track
---@param reset boolean?
---@return NBS.MusicPlayer
function MusicPlayer:setTrack(track,reset)
	self.track=track
	if reset then
		self.tick=0
	end
	return self
end


---Sets the attenuation of the music player.
---@param attenuation number
---@return NBS.MusicPlayer
function MusicPlayer:setAttenuation(attenuation)
	self.attenuation=attenuation
	return self
end


---Sets the volume of the music player.
---@param volume number
---@return NBS.MusicPlayer
function MusicPlayer:setVolume(volume)
	self.volume=volume
	return self
end


---@param buffer Buffer
local function readString(buffer)
	local len=buffer:readIntLE()
	local str=buffer:readString(len)
	return str
end

---Loads a given .NBS file into a Music track object.  
---`NBS.loadTrack(<path>)` -> `<path>.nbs`
---@param path string
---@return NBS.Track
function Nbs.loadFromPath(path)
	local stream=resources:get(path..".nbs")
	assert(stream, 'Could not find "'..path..'.nbs"')
	local buffer=data:createBuffer(stream:available())
	buffer:readFromStream(stream)
	buffer:setPosition(0)
	-- check if NBS version is valid
	
	return Nbs.parseBuffer(buffer)
end

---@param buffer Buffer
---@return NBS.Track
function Nbs.parseBuffer(buffer)
	assert(buffer:readShort() == 0, 'attempted to load a legacy NBS file')
	--[────────────────────────-< HEADER >-────────────────────────]--
	local version=buffer:read()
	local instrumentCount=buffer:read()
	local songLength=buffer:readShortLE() -- in ticks, divide by tempo to get in seconds.
	local layerCount=buffer:readShortLE()
	local songName=readString(buffer)
	local songAuthor=readString(buffer)
	local songOriginalAuthor=readString(buffer)
	local songDescription=readString(buffer)
	local songTempo=buffer:readShortLE() / 100 -- The tempo of the song multiplied by 100 (for example, 1225 instead of 12.25). Measured in ticks per second.
	buffer:read()
	buffer:read()
	local timeSignature=buffer:read() -- The time signature of the song. If this is 3, then the signature is 3/4. Default is 4. This value ranges from 2-8.
	-- skip over unused header information
	buffer:readInt() -- minutes spent
	buffer:readInt() -- left clicks
	buffer:readInt() -- right clicks
	buffer:readInt() -- noteblocks added
	buffer:readInt() -- note blocks removed
	
	local new={
		version=version,
		instrumentCount=instrumentCount,
		songLength=songLength,
		layerCount=layerCount,
		songName=songName,
		songAuthor=songAuthor,
		songOriginalAuthor=songOriginalAuthor,
		songDescription=songDescription,
		songTempo=songTempo,
		timeSignature=timeSignature,
		
	}
	
	readString(buffer) -- Schematic file name
	local loop=buffer:read() ~= 0 and true or false
	local maxLoopCount=buffer:read()
	new.maxLoopCount=maxLoopCount==0 and math.huge or maxLoopCount
	new.loopStartTick=buffer:read()
	new.loop=loop
	
	--[────────────────────────-< BODY >-────────────────────────]--
	
	local c=0
	local notes={}
	
	local tick=-1
	local loudest = 0
	
	for i=1, 100000 do -- tick loop
		local jump=buffer:readShort()
		if jump == 0 then
			break -- End of note block section
		end
		tick=tick+jump
	
		local layer=-1 -- reset layer counter per tick
	
		for j=1, 100000 do -- layer loop
			local layerJump=buffer:readShort()
			if layerJump == 0 then
				break -- end of layers for this tick
			end
		
			layer=layer+layerJump -- update layer number
		
			local u=buffer:read() -- idk why
			local instrument=buffer:read()
			local key=buffer:read()
			local volume=buffer:read() -- panning (ignored here)
			local pitch=buffer:readShortLE()
			c=c+1
			local noteblock={
				tick=tick,
				layer=layer,
				instrument=instrument,
				key=key,
				volume=volume/255,
				pitch=pitch
			}
			loudest = math.max(loudest, noteblock.volume)
			notes[c]=noteblock
		end
	end
	new.loudest = loudest
	new.notes=notes
	return new
end

--[[ <- playground, separate [[ to run

local track=Nbs.loadTrack("cool")
local player=Nbs.newMusicPlayer(track)

player:setPos(client:getCameraPos()+client:getCameraDir())
player:play()
player:setSpeed(1)
player:setOctaveShift(2)

---@param note NBS.Noteblock
player.NOTE_PLAYED:register(function (note)
	-- do stuff
end)
--]]

return Nbs