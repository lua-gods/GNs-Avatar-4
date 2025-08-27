### Class Name: `NBS.MusicPlayer`
the one that handles the music playing
# Properties
|Type|Field|Description| |
|-|-|-|-|
|`number`|attenuation|...| |
|`integer`|currentNote|...| |
|`integer`|currentNoteTick|...| |
|`boolean`|isPlaying|...| |
|`Event`|NOTE_PLAYED|...| |
|`Vector3`|pos|...| |
|`number`|speed|...| |
|`integer`|tick|...| |
|`NBS.Track`|track|...| |
|`number`|transposition|...| |
|`number`|volume|...| |
# Methods
|Returns|Methods|
|-|-|
|`NBS.MusicPlayer`|MusicPlayer:[play](#MusicPlayerplay)()|
|`NBS.MusicPlayer`|MusicPlayer:[stop](#MusicPlayerstop)()|
|`NBS.MusicPlayer`|MusicPlayer:[pause](#MusicPlayerpause)()|
|`NBS.MusicPlayer`|MusicPlayer:[setSpeed](#MusicPlayersetSpeedspeed)(speed : number?)|
|`NBS.MusicPlayer`|MusicPlayer:[setTempoOverride](#MusicPlayersetTempoOverridetempo)(tempo : number)|
|`NBS.MusicPlayer`|MusicPlayer:[setOctaveShift](#MusicPlayersetOctaveShiftshift)(shift : integer)|
|`NBS.MusicPlayer`|MusicPlayer:[setPos](#MusicPlayersetPosx-y-z)(x : number, y : number, z : number)|
||MusicPlayer:[setPos](#MusicPlayersetPosxyz)(xyz : Vector3)|
|`NBS.MusicPlayer`|MusicPlayer:[setTrack](#MusicPlayersetTracktrack-reset)(track : NBS.Track, reset : boolean?)|
|`NBS.MusicPlayer`|MusicPlayer:[setAttenuation](#MusicPlayersetAttenuationattenuation)(attenuation : number)|
|`NBS.MusicPlayer`|MusicPlayer:[setVolume](#MusicPlayersetVolumevolume)(volume : number)|
## `MusicPlayer:play()`
Plays the song / Continues where it stops.  
### Returns `NBS.MusicPlayer`

## `MusicPlayer:stop()`
Stops the playback of the song, resetting the playback time.  
### Returns `NBS.MusicPlayer`

## `MusicPlayer:pause()`
Stops the playback of the song, without resetting the playback time.  
### Returns `NBS.MusicPlayer`

## `MusicPlayer:setSpeed(speed)`
Sets the playback speed.  
### Arguments
- `number?` `speed`

### Returns `NBS.MusicPlayer`

## `MusicPlayer:setTempoOverride(tempo)`
Sets the tempo the songs played will use. leaving it nil will use the song's default tempo.    
NOTE: the tempo is in ticks per second. not Beats per Minute  
### Arguments
- `number` `tempo`

### Returns `NBS.MusicPlayer`

## `MusicPlayer:setOctaveShift(shift)`
Sets the octave transposition of the song.  
### Arguments
- `integer` `shift`

### Returns `NBS.MusicPlayer`

## `MusicPlayer:setPos(x, y, z)`
### Arguments
- `number` `x`

- `number` `y`

- `number` `z`

### Returns `NBS.MusicPlayer`

## `MusicPlayer:setPos(xyz)`
### Arguments
- `Vector3` `xyz`


## `MusicPlayer:setTrack(track, reset)`
Sets the track to be played.  
### Arguments
- `NBS.Track` `track`

- `boolean?` `reset`

### Returns `NBS.MusicPlayer`

## `MusicPlayer:setAttenuation(attenuation)`
Sets the attenuation of the music player.  
### Arguments
- `number` `attenuation`

### Returns `NBS.MusicPlayer`

## `MusicPlayer:setVolume(volume)`
Sets the volume of the music player.  
### Arguments
- `number` `volume`

### Returns `NBS.MusicPlayer`


***
***

### Class Name: `NBS.Track`
the one that holds the notes
# Properties
|Type|Field|Description| |
|-|-|-|-|
|`integer`|instrumentCount|...| |
|`integer`|layerCount|...| |
|`boolean`|loop|...| |
|`integer`|loopStartTick|...| |
|`integer`|maxLoopCount|...| |
|`string`|name|...| |
|`NBS.Noteblock[]`|notes|...| |
|`string`|songAuthor|...| |
|`string`|songDescription|...| |
|`integer`|songLength|...| |
|`string`|songName|...| |
|`string`|songOriginalAuthor|...| |
|`integer`|songTempo|...| |
|`integer`|timeSignature|...| |

***
***

### Class Name: `NBS.Noteblock`
a representation of a noteblock in Note Block Studio's format
# Properties
|Type|Field|Description| |
|-|-|-|-|
|`integer`|instrument|...| |
|`integer`|key|...| |
|`integer`|pitch|...| |
|`integer`|tick|...| |
|`integer`|volume|...| |