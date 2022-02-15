extends Node
class_name SubtitleData

# The text key for the subtitle
# because labels are used, if there is a registered translation locale, Godot will automatically try to translate this. If no translation is registered, this is left as is.
# for quick subtitles, the literal subtitle text may be placed here
# if this should be treated as a character's dialogue, place the character's name before the key, seperated with a ":" eg "char_name:dialogue_key". This is handled in the system to seperate the speaker and audio subtitles
export (String) var subtitle_key := ""

# how much time after the length of the audio clip should the subtitle persist?
# this is good for shorter audio clips which could easily be missed
# setting this to be negative will shorten the subtitle. Which can cause problems in some cases
export (float) var subtitles_padding := 0.0

# a path to a node which will override the position calculations for the subtitle. 
# This can be any node, but only Node2D and Spatial derived nodes will affect the positioning
# if this is null, the parent node is used
export (NodePath) var subtitle_position_override : NodePath

# A theme to override the generated subtitle. If this is null, it will use the default theme determined by the addon. This can be null
export (Theme) var subtitle_theme_override : Theme = null

# this signal is emitted when this script detects that the parent audio stream is played
signal on_play

# cached value of parent:playing
var _last_check := false

# gets the node from the path export. Can be null, the subtitle system handles null as not using an override and defaults to the parent of this node (An audio stream player)
var pos_override :Node = null

# the parent node
# This node MUST be parented to an AudioStreamPlayer, AudioStreamPlayer2D, or AudioStreamPlayer3D, or a derived stream player. Otherwise the system will fail to recognize it.
onready var parent :Node = get_parent()


func _ready() -> void:
	if subtitle_position_override:
		pos_override = get_node(subtitle_position_override)

func _process(delta: float) -> void:
	var cur :bool = parent.playing # this will throw an error if the parent isn't an AudioStreamPlayer node. Check the node parent if you got here from the debugger!
	if cur and not _last_check:
		trigger_audio_play()
	var asp := parent as AudioStreamPlayer
	_last_check = cur

func trigger_audio_play() -> void:
	emit_signal("on_play") # this addon does not make use of this signal, but it is there should a need exist
	Subtitles.add_subtitle(self, parent, subtitle_theme_override)
