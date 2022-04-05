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

# determines whether to push this subtitle to the dialogue layer or to a spatialized layer. 
# character dialogues are handled in a way that assumes it is crucial the player is able to read them all. They are not required to have any specific character information in the subtitle_key
export (bool) var is_character_dialogue := false

# a path to a node which will override the position calculations for the subtitle. 
# This can be any node, but only Node2D and Spatial derived nodes will affect the positioning
# if this is null, the parent node is used
export var subtitle_position_override : NodePath

# A theme to override the generated subtitle. If this is null, it will use the default theme determined by the addon. This can be null
export (Theme) var subtitle_theme_override : Theme = null

# this signal is emitted when this script detects that the parent audio stream is played
signal on_play

# cached value of parent:playing
var _last_check := false

# the parent node
# This node MUST be parented to an AudioStreamPlayer, AudioStreamPlayer2D, or AudioStreamPlayer3D, or a derived stream player. Otherwise the system will fail to recognize it.
onready var parent :Node = get_parent()

var is_event_driven := false

func _ready() -> void:
	if parent.has_signal("audio_start"):
		parent.connect("audio_start", self, "trigger_audio_play")
		is_event_driven = true
		self.set_process(false)
	else:
		# if this is intended, feel free to delete the warning push
		push_warning("SubtitleNode [%s] will be running in process mode, use the 'Attach Event Scripts in Scene' tool to attach scripts to convert standard AudioStreamPlayers into event driven players. This will only work for built-in AudioStreamPlayer nodes" % get_path())

func _process(delta: float) -> void:
	var cur :bool = parent.playing # this will throw an error if the parent isn't an AudioStreamPlayer node. Check the node parent if you got here from the debugger!
	if cur and not _last_check:
		trigger_audio_play()
	_last_check = cur

func trigger_audio_play() -> void:
	emit_signal("on_play") # this addon does not make use of this signal, but it is there should a need exist
	get_tree().root.get_node("Subtitles").add_subtitle(self, parent)
