--- UUID 3dfb6d3b-74e3-4628-9747-1ab586e2fd65



---@class DrumAPI
local DrumAPI = {}


---@alias DrumAPI.keyID string
---| "B1" # Base Drum
---| "C\x232" # Snare
---| "D2" # Snare Drum
---| "F2" # Floor Tom Drum
---| "A2" # Mid Tom Drum
---| "B2" # High Tom Drum
---| "D\x233" # Ride Cymbal
---| "C\x233" # Crash Cymbal
---| "A\x232" # High Hat Cymbal
---| "F\x232" # High Hat Cymbal (soft)
---| "G\x232" # High Hat Cymbal (softer)
---| "A\x233" # Rattle (secret instrument?)

---@param drumID string
---@param keyID DrumAPI.keyID
---@param doesPlaySound boolean
---@param notePos Vector3
---@param noteVolume number
function DrumAPI.playNote(drumID, keyID, doesPlaySound, notePos, noteVolume)
end


---@param keyID DrumAPI.keyID
---@param notePos Vector3
---@param noteVolume number
function DrumAPI.playSound(keyID,notePos,noteVolume)
end

---@return boolean
function DrumAPI.validPos() return false end

---@return string[]
function DrumAPI.getDrumIDs() return {} end

---@return Vector3[]
function DrumAPI.getDrumPositions() return {} end

---@return Vector3?
function DrumAPI.getNearestDrumID() return nil end