local NBS = require("lib.nbs")

-- loads the track `musics/cool.nbs` 
local track = NBS.loadFromPath("musics/cool")
local musicPlayer = NBS.newMusicPlayer(track)

function events.ENTITY_INIT()
	musicPlayer:setPos(player:getPos()) -- plays the song where the camera is
	:setSpeed(0.5) -- plays the song at 0.5x the speed
	:play() -- starts the song
	
end
-- do something when a note is played
---@param note NBS.Noteblock
musicPlayer.NOTE_PLAYED:register(function (note)
      -- do stuff
end)
-- NOTE: NOTE_PLAYED requires GN Events Library to be installed