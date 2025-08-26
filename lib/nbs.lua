local params=require("lib.params")


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
---@field notes NBS.Noteblock[]

local Nbs={}

---@class NBS.Noteblock
---@field tick integer
---@field instrument integer
---@field key integer
---@field volume integer
---@field pitch integer


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

for i, v in pairs(instruments) do
	instruments[i]="minecraft:block.note_block"..v
end


local activeMusicPlayers={}

local lastTime=client:getSystemTime()

function events.WORLD_RENDER()
	local time=client:getSystemTime()
	local delta=(time-lastTime) / 1000
	lastTime=time
	
	
	---@param mp NBS.MusicPlayer
	for _, mp in pairs(activeMusicPlayers) do
		
		mp.tick=mp.tick+delta * mp.track.songTempo
		
		for i=1, 10, 1 do
			local currentNote=mp.track.notes[mp.currentNote]
			if currentNote then
				if mp.tick >= currentNote.tick then
					mp.currentNote=mp.currentNote+math.sign(mp.tick-currentNote.tick)
					local pitch=2^(((currentNote.key-9)/12)-3)
					sounds[instruments[currentNote.instrument]]:pos(mp.pos):pitch(pitch):volume(currentNote.volume):play()
					mp.NOTE_PLAYED:invoke(currentNote)
				else
					break
				end
			end
		end
		
		if mp.tick >= mp.track.songLength then
			mp.tick=mp.tick-mp.track.songLength
			mp.currentNote=1
		end
	end
end



---@class NBS.MusicPlayer
---@field NOTE_PLAYED Event
---@field track NBS.Track
---@field tick integer
---@field pos Vector3
---@field currentNote integer
---@field isPlaying boolean
local MusicPlayer={}
MusicPlayer.__index=MusicPlayer

local Events = require("lib.event")

---@param track NBS.Track?
---@return NBS.MusicPlayer
function Nbs.newMusicPlayer(track)
	local new={
		track=track,
		tick=0,
		pos=vec(0,0,0),
		currentNote=1,
		isPlaying=false,
		NOTE_PLAYED = Events.new()
	}
	return setmetatable(new,MusicPlayer)
end



---@param reset boolean?
---@return NBS.MusicPlayer
function MusicPlayer:play(reset)
	activeMusicPlayers[self]=self
	self.isPlaying=true
	if reset then
		self.currentNote=1
		self.tick=-2
	end
	return self
end


---@return NBS.MusicPlayer
function MusicPlayer:stop()
	activeMusicPlayers[self]=nil
	self.isPlaying=false
	return self
end


---@overload fun(xyz: Vector3)
---@param x number
---@param y number
---@param z number
---@return NBS.MusicPlayer
function MusicPlayer:setPos(x,y,z)
	local pos=params.vec3(x,y,z)
	self.pos=pos
	return self
end


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



---@param buffer Buffer
local function readString(buffer)
	local len=buffer:readIntLE()
	local str=buffer:readString(len)
	return str
end

---@param path string
---@return NBS.Track
function Nbs.loadTrack(path)
	local stream=resources:get(path..".nbs")
	assert(stream, 'Could not find "'..path..'.nbs"')
	local buffer=data:createBuffer(stream:available())
	buffer:readFromStream(stream)
	buffer:setPosition(0)
	-- check if NBS version is valid
	assert(buffer:readShort() == 0, 'Legacy NBS File is not supported')
	
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
	local loopStartTick=buffer:read()
	
	new.loop=loop
	
	--[────────────────────────-< BODY >-────────────────────────]--
	
	local c=0
	local notes={}
	
	local tick=-1
	
	for i=1, 10000 do -- tick loop
		local jump=buffer:readShort()
		if jump == 0 then
			break -- End of note block section
		end
		tick=tick+jump
	
		local layer=-1 -- reset layer counter per tick
	
		for j=1, 1000 do -- layer loop
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
			notes[c]=noteblock
		end
	end
	
	new.notes=notes
	return new
end

--[[ <- playground, separate [[ to run
	
local track=Nbs.loadTrack("plant")
local player=MusicPlayer.new(track)

player:setPos(client:getCameraPos()+client:getCameraDir())
player:play()
--]]

return Nbs